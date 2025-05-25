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
Create outline configuration environment variables.
*/}}
{{- define "outline.env" -}}
{{- range $k, $v := .values }}
  {{- if kindIs "map" $v }}
    {{- range $sk, $sv := $v }}
      {{- include "outline.env" (dict "root" $.root "values" (dict (printf "%s_%s" (upper $k) (upper $sk)) $sv)) }}
    {{- end }}
  {{- else }}
    {{- $value := $v }}
    {{- if or (kindIs "bool" $v) (kindIs "float64" $v) (kindIs "int" $v) (kindIs "int64" $v) }}
      {{- $v = $v | toString | b64enc | quote -}}
    {{- else }}
      {{- $v = tpl $v $.root | toString | b64enc | quote }}
    {{- end }}
    {{- if and ($v) (ne $v "\"\"") }}
{{ upper $k }}: {{ $v }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

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
  {{- if eq "local" $.Values.outline.file_storage }}
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
