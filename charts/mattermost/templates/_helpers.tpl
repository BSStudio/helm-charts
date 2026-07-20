{{/*
Expand the name of the chart.
*/}}
{{- define "mattermost.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mattermost.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mattermost.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mattermost.labels" -}}
helm.sh/chart: {{ include "mattermost.chart" . }}
{{ include "mattermost.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mattermost.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mattermost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mattermost.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mattermost.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container-level security context for the application container.
Merged as a dict so user keys override the defaults rather than being appended as duplicates.
*/}}
{{- define "mattermost.containerSecurityContext" -}}
{{- $defaults := dict
  "runAsUser" 65534
  "runAsGroup" 65534
  "allowPrivilegeEscalation" false
  "runAsNonRoot" true
  "readOnlyRootFilesystem" true
  "capabilities" (dict "drop" (list "ALL"))
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.securityContext))) }}
{{- end }}

{{/*
Pod-level security context shared by every pod.
*/}}
{{- define "mattermost.podSecurityContext" -}}
{{- $defaults := dict
  "seccompProfile" (dict "type" "RuntimeDefault")
  "fsGroup" 65534
  "fsGroupChangePolicy" "OnRootMismatch"
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.podSecurityContext))) }}
{{- end }}

{{/*
Non-secret environment variables. Empty values are dropped so that blanking a default in a values
file removes the variable rather than setting it to "".
*/}}
{{- define "mattermost.config" -}}
{{- range $k, $v := .Values.config }}
{{- $rendered := tpl ($v | toString) $ }}
{{- if $rendered }}
{{ $k }}: {{ $rendered | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Sensitive environment variables. MM_CONFIG (the config store) and MM_SQLSETTINGS_DATASOURCE (the data
store) both default to the bundled database, keeping `postgres.auth` the single source of truth for
the credentials; setting either explicitly is what pointing at an external database looks like.
*/}}
{{- define "mattermost.secrets" -}}
{{- $computed := dict -}}
{{- if and .Values.postgres.enabled .Values.postgres.auth.password -}}
{{- $auth := .Values.postgres.auth -}}
{{- $dsn := printf "postgres://%s:%s@%s-postgres:5432/%s?sslmode=disable&connect_timeout=10" $auth.username $auth.password .Release.Name $auth.database -}}
{{- $_ := set $computed "MM_CONFIG" $dsn -}}
{{- $_ := set $computed "MM_SQLSETTINGS_DATASOURCE" $dsn -}}
{{- end -}}
{{- $user := dict -}}
{{- if not .Values.existingSecret -}}
{{- range $k, $v := .Values.secrets -}}
{{- $rendered := tpl ($v | toString) $ -}}
{{- if $rendered -}}
{{- $_ := set $user $k $rendered -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- range $k, $v := merge $user $computed }}
{{ $k }}: {{ $v | b64enc | quote }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the user-supplied secrets, for consumers that read a single key.
*/}}
{{- define "mattermost.secretName" -}}
{{- default (include "mattermost.fullname" .) .Values.existingSecret }}
{{- end }}
