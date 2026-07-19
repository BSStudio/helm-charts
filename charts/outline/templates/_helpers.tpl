{{/*
Expand the name of the chart.
*/}}
{{- define "outline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "outline.fullname" -}}
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
{{- define "outline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "outline.labels" -}}
helm.sh/chart: {{ include "outline.chart" . }}
{{ include "outline.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "outline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "outline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "outline.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "outline.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container-level security context for the application container.
Merged as a dict so user keys override the defaults rather than being appended as duplicates.
*/}}
{{- define "outline.containerSecurityContext" -}}
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
{{- define "outline.podSecurityContext" -}}
{{- $defaults := dict
  "seccompProfile" (dict "type" "RuntimeDefault")
  "fsGroup" 65534
  "fsGroupChangePolicy" "OnRootMismatch"
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.podSecurityContext))) }}
{{- end }}

{{/*
Security contexts for the scheduler CronJob. Separate from the application ones: it runs busybox and
mounts no volumes.
*/}}
{{- define "outline.schedulerPodSecurityContext" -}}
{{- $defaults := dict
  "seccompProfile" (dict "type" "RuntimeDefault")
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.scheduler.podSecurityContext))) }}
{{- end }}

{{- define "outline.schedulerSecurityContext" -}}
{{- $defaults := dict
  "runAsUser" 65534
  "runAsGroup" 65534
  "allowPrivilegeEscalation" false
  "runAsNonRoot" true
  "readOnlyRootFilesystem" true
  "capabilities" (dict "drop" (list "ALL"))
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.scheduler.securityContext))) }}
{{- end }}

{{/*
Non-secret environment variables. Empty values are dropped so that blanking a default in a values
file removes the variable rather than setting it to "".
*/}}
{{- define "outline.config" -}}
{{- range $k, $v := .Values.config }}
{{- $rendered := tpl ($v | toString) $ }}
{{- if $rendered }}
{{ $k }}: {{ $rendered | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Sensitive environment variables. The connection strings default to the bundled sub-charts, keeping
`postgres.auth` the single source of truth for the credentials; setting either explicitly is what
pointing at an external database or cache looks like.
*/}}
{{- define "outline.secrets" -}}
{{- $computed := dict -}}
{{- if and .Values.postgres.enabled .Values.postgres.auth.password -}}
{{- $auth := .Values.postgres.auth -}}
{{- $_ := set $computed "DATABASE_URL" (printf "postgres://%s:%s@%s-postgres:5432/%s" $auth.username $auth.password .Release.Name $auth.database) -}}
{{- end -}}
{{- if .Values.redis.enabled -}}
{{- $_ := set $computed "REDIS_URL" (printf "redis://%s-redis:6379" .Release.Name) -}}
{{- end -}}
{{- $user := dict -}}
{{- range $k, $v := .Values.secrets -}}
{{- $rendered := tpl ($v | toString) $ -}}
{{- if $rendered -}}
{{- $_ := set $user $k $rendered -}}
{{- end -}}
{{- end -}}
{{- range $k, $v := merge $user $computed }}
{{ $k }}: {{ $v | b64enc | quote }}
{{- end }}
{{- end }}

{{/*
Transform environment variables to be added to secret.
*/}}
{{- define "outline.envVars" -}}
{{- range $env := .Values.env }}
  {{- if and (hasKey $env "name") (hasKey $env "value") }}
{{ $env.name }}: {{ $env.value | toString | b64enc | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Generate environment variables.
*/}}
{{- define "outline.generateEnvVars" -}}
  {{- $envVarsWithValueFrom := list -}}
  {{- range $env := .Values.env -}}
    {{- if and (hasKey $env "name") (hasKey $env "valueFrom") -}}
      {{- $envVarsWithValueFrom = append $envVarsWithValueFrom (dict "name" $env.name "valueFrom" $env.valueFrom) }}
    {{- end -}}
  {{- end -}}
  env:
  - name: NODE_ENV
    value: "production"
  - name: HOME
    value: "/tmp"
  - name: FORCE_HTTPS
    value: "false"
  - name: PORT
    value: {{ .Values.service.port | quote }}
  {{- if eq "local" (.Values.config.FILE_STORAGE | toString) }}
  - name: FILE_STORAGE_LOCAL_ROOT_DIR
    value: "/var/lib/outline/data"
  {{- end }}
  {{- if not (empty $envVarsWithValueFrom) }}
  {{- range $env := $envVarsWithValueFrom }}
  - name: {{ $env.name }}
    valueFrom:
{{ toYaml $env.valueFrom | indent 6 }}
  {{- end }}
  {{- end }}
{{- end -}}
