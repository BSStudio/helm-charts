{{/*
Expand the name of the chart.
*/}}
{{- define "website.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "website.fullname" -}}
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
{{- define "website.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "website.labels" -}}
helm.sh/chart: {{ include "website.chart" . }}
{{ include "website.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "website.selectorLabels" -}}
app.kubernetes.io/name: {{ include "website.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "website.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "website.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the OOB config file, chart-managed unless `oobConfig.existingSecret` is set.
*/}}
{{- define "website.oobConfigSecretName" -}}
{{- if .Values.oobConfig.existingSecret }}
{{- .Values.oobConfig.existingSecret }}
{{- else }}
{{- printf "%s-oob-config" (include "website.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Container-level security context for the application container.
Merged as a dict so user keys override the defaults rather than being appended as duplicates.
*/}}
{{- define "website.containerSecurityContext" -}}
{{- $defaults := dict
  "runAsUser" 65532
  "runAsGroup" 65532
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
{{- define "website.podSecurityContext" -}}
{{- $defaults := dict
  "seccompProfile" (dict "type" "RuntimeDefault")
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.podSecurityContext))) }}
{{- end }}

{{/*
Non-secret environment variables. Empty values are dropped so that blanking a default in a values
file removes the variable rather than setting it to "".
*/}}
{{- define "website.config" -}}
{{- range $k, $v := .Values.config }}
{{- $rendered := tpl ($v | toString) $ }}
{{- if $rendered }}
{{ $k }}: {{ $rendered | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Sensitive environment variables. DATABASE_URL defaults to the bundled sub-chart, keeping
`postgres.auth` the single source of truth for the credentials; setting it explicitly is what
pointing at an external database looks like.
*/}}
{{- define "website.secrets" -}}
{{- $computed := dict -}}
{{- if and .Values.postgres.enabled .Values.postgres.auth.password -}}
{{- $auth := .Values.postgres.auth -}}
{{- $_ := set $computed "DATABASE_URL" (printf "postgresql://%s:%s@%s-postgres:5432/%s" $auth.username $auth.password .Release.Name $auth.database) -}}
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
Environment variables the chart derives from other values, followed by the user's `extraEnv`
entries. Anything a user should be able to change belongs in `config` or `secrets` instead: `env`
wins over the ConfigMap and Secret, so entries here silently override them.
*/}}
{{- define "website.env" -}}
- name: PORT
  value: {{ .Values.service.port | quote }}
- name: BSS_OOB_CONFIG
  value: /app/oob/config.json
{{- with .Values.extraEnv }}
{{ toYaml . }}
{{- end }}
{{- end }}
