{{/*
Expand the name of the chart.
*/}}
{{- define "raktr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "raktr.fullname" -}}
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
{{- define "raktr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "raktr.labels" -}}
helm.sh/chart: {{ include "raktr.chart" . }}
{{ include "raktr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "raktr.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "raktr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "raktr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "raktr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "raktr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container-level security context shared by both workloads.
Merged as a dict so user keys override the defaults instead of being appended as duplicates.
*/}}
{{- define "raktr.containerSecurityContext" -}}
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
{{- define "raktr.podSecurityContext" -}}
{{- $defaults := dict
  "seccompProfile" (dict "type" "RuntimeDefault")
  "fsGroup" 65532
  "fsGroupChangePolicy" "OnRootMismatch"
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.podSecurityContext))) }}
{{- end }}

{{/*
Non-secret connection defaults derived from the bundled sub-chart. User supplied `.Values.backend.config`
keys win over these computed defaults.
*/}}
{{- define "raktr.backendComputedConfig" -}}
{{- $cfg := dict -}}
{{- if .Values.postgres.enabled -}}
{{- $_ := set $cfg "SPRING_DATASOURCE_URL" (printf "jdbc:postgresql://%s-postgres:5432/%s" .Release.Name (.Values.postgres.auth.database | toString)) -}}
{{- $_ := set $cfg "SPRING_DATASOURCE_USERNAME" (.Values.postgres.auth.username | toString) -}}
{{- end -}}
{{- $cfg | toYaml -}}
{{- end }}

{{/*
The merged, non-secret configuration (computed defaults + user overrides). Empty values are dropped
so that blanking a default in a values file removes the variable rather than setting it to "".
*/}}
{{- define "raktr.backendConfig" -}}
{{- $computed := fromYaml (include "raktr.backendComputedConfig" .) -}}
{{- $user := dict -}}
{{- range $k, $v := .Values.backend.config -}}
{{- if not (kindIs "invalid" $v) -}}
{{- $rendered := tpl ($v | toString) $ -}}
{{- if $rendered -}}
{{- $_ := set $user $k $rendered -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- range $k, $v := merge $user $computed }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
The frontend's environment. Blanking a value leaves the image's own default rather than "".
*/}}
{{- define "raktr.frontendConfig" -}}
{{- $cfg := dict -}}
{{- range $k, $v := .Values.frontend.config -}}
{{- if not (kindIs "invalid" $v) -}}
{{- $rendered := tpl ($v | toString) $ -}}
{{- if $rendered -}}
{{- $_ := set $cfg $k $rendered -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- range $k, $v := $cfg }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
The backend's sensitive environment variables. SPRING_DATASOURCE_PASSWORD is derived from
`postgres.auth` so the bundled sub-chart stays the single source of truth for it; that stays true
under `existingSecret`, which replaces only the user-supplied `secrets`.
*/}}
{{- define "raktr.backendSecrets" -}}
{{- $computed := dict -}}
{{- if and .Values.postgres.enabled .Values.postgres.auth.password -}}
{{- $_ := set $computed "SPRING_DATASOURCE_PASSWORD" (.Values.postgres.auth.password | toString) -}}
{{- end -}}
{{- $user := dict -}}
{{- if not .Values.backend.existingSecret -}}
{{- range $k, $v := .Values.backend.secrets -}}
{{- if not (kindIs "invalid" $v) -}}
{{- $rendered := tpl ($v | toString) $ -}}
{{- if $rendered -}}
{{- $_ := set $user $k $rendered -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- range $k, $v := merge $user $computed }}
{{ $k }}: {{ $v | b64enc | quote }}
{{- end }}
{{- end }}

{{/*
Environment variables the chart sets on the backend, followed by the user's `extraEnv` entries.
The context path is fixed: the frontend calls the API at `/api` on its own origin, and the ingress
routes that prefix to the backend unchanged. `env` wins over `envFrom`, so `config` cannot move it.
*/}}
{{- define "raktr.backendEnv" -}}
- name: SERVER_SERVLET_CONTEXT_PATH
  value: /api
{{- with .Values.backend.extraEnv }}
{{ toYaml . }}
{{- end }}
{{- end }}
