{{/*
Expand the name of the chart.
*/}}
{{- define "request-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "request-manager.fullname" -}}
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
{{- define "request-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "request-manager.labels" -}}
helm.sh/chart: {{ include "request-manager.chart" . }}
{{ include "request-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "request-manager.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "request-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "request-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "request-manager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "request-manager.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The application's sensitive environment variables. DATABASE_PASSWORD is derived from
`postgres.auth` so the bundled sub-chart stays the single source of truth for it; that stays true
under `existingSecret`, which replaces only the user-supplied `secrets`.
*/}}
{{- define "request-manager.secrets" -}}
{{- $computed := dict -}}
{{- if and .Values.postgres.enabled .Values.postgres.auth.password -}}
{{- $_ := set $computed "DATABASE_PASSWORD" .Values.postgres.auth.password -}}
{{- end -}}
{{- $user := dict -}}
{{- if not .Values.existingSecret -}}
{{- range $k, $v := .Values.secrets -}}
{{- if and (not (kindIs "invalid" $v)) (ne ($v | toString) "") -}}
{{- $_ := set $user $k ($v | toString) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- range $k, $v := merge $user $computed }}
{{ $k }}: {{ $v | b64enc | quote }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds the Google service account key file.
*/}}
{{- define "request-manager.credentialsSecretName" -}}
{{- if .Values.credentials.existingSecret }}
{{- .Values.credentials.existingSecret }}
{{- else }}
{{- printf "%s-credentials" (include "request-manager.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Whether pods block until migrations are applied. Unset follows migrations.enabled.
*/}}
{{- define "request-manager.waitForMigrations" -}}
{{- if kindIs "invalid" .Values.migrations.waitForMigrations -}}
{{- .Values.migrations.enabled -}}
{{- else -}}
{{- .Values.migrations.waitForMigrations -}}
{{- end -}}
{{- end }}

{{/*
initContainer that blocks until migrations are applied. `migrate --check` applies nothing and
exits non-zero while any are pending, so every pod can run it concurrently.
*/}}
{{- define "request-manager.waitForMigrationsInitContainer" -}}
- name: wait-for-migrations
  securityContext:
    {{- include "request-manager.containerSecurityContext" . | nindent 4 }}
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  imagePullPolicy: {{ .Values.image.imagePullPolicy }}
  args:
    - sh
    - -c
    - >-
      timeout {{ .Values.migrations.waitTimeout }} sh -c
      'until python manage.py migrate --check; do
      echo "waiting for migrations..."; sleep 5; done'
  env:
    {{- include "request-manager.env" . | nindent 4 }}
  envFrom:
    {{- include "request-manager.envFrom" . | nindent 4 }}
  resources:
    {{- toYaml .Values.migrations.resources | nindent 4 }}
  volumeMounts:
    {{- include "request-manager.volumeMounts" . | nindent 4 }}
{{- end }}

{{/*
Non-secret connection defaults derived from the bundled sub-charts. User supplied
`.Values.config` keys win over these computed defaults.
*/}}
{{- define "request-manager.computedConfig" -}}
{{- $cfg := dict -}}
{{- if .Values.postgres.enabled -}}
{{- $_ := set $cfg "DATABASE_HOST" (printf "%s-postgres" .Release.Name) -}}
{{- $_ := set $cfg "DATABASE_PORT" "5432" -}}
{{- $_ := set $cfg "DATABASE_NAME" (.Values.postgres.auth.database | toString) -}}
{{- $_ := set $cfg "DATABASE_USER" (.Values.postgres.auth.username | toString) -}}
{{- end -}}
{{- if .Values.redis.enabled -}}
{{- $host := printf "%s-redis" .Release.Name -}}
{{- $_ := set $cfg "CACHE_REDIS" (printf "redis://%s:6379/0" $host) -}}
{{- $_ := set $cfg "CELERY_BROKER" (printf "redis://%s:6379/1" $host) -}}
{{- end -}}
{{- if .Values.credentials.enabled -}}
{{- $_ := set $cfg "GOOGLE_SERVICE_ACCOUNT_KEY_FILE_NAME" (.Values.credentials.fileName | toString) -}}
{{- end -}}
{{- $cfg | toYaml -}}
{{- end }}

{{/*
The merged, non-secret configuration map (computed defaults + user overrides).
ALLOWED_HOSTS is excluded; "request-manager.env" renders it instead.
*/}}
{{- define "request-manager.config" -}}
{{- $computed := fromYaml (include "request-manager.computedConfig" .) -}}
{{- $user := dict -}}
{{- range $k, $v := .Values.config -}}
{{- $_ := set $user $k ($v | toString) -}}
{{- end -}}
{{- merge (omit $user "ALLOWED_HOSTS") $computed | toYaml -}}
{{- end }}

{{/*
Environment variables shared by every application container.
ALLOWED_HOSTS lives here, not in the ConfigMap, so it can pick up the pod IP: probes carry it as
the Host header and Django 400s any host it does not list. The Service name covers `helm test`.
*/}}
{{- define "request-manager.env" -}}
- name: DJANGO_CONTAINER
  value: "false"
- name: HOME
  value: /tmp
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: ALLOWED_HOSTS
  value: "$(POD_IP),127.0.0.1,localhost,{{ include "request-manager.fullname" . }}{{ with (default dict .Values.config).ALLOWED_HOSTS }},{{ . }}{{ end }}"
{{- end }}

{{/*
envFrom sources shared by every application container.
*/}}
{{- define "request-manager.envFrom" -}}
- configMapRef:
    name: {{ include "request-manager.fullname" . }}
- secretRef:
    name: {{ include "request-manager.fullname" . }}
{{- with .Values.existingSecret }}
- secretRef:
    name: {{ . }}
{{- end }}
{{- with .Values.extraEnvFrom }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Volumes shared by every application container. `/tmp` must be writable because the root
filesystem is read-only.
*/}}
{{- define "request-manager.volumes" -}}
- name: tmp
  emptyDir:
    medium: Memory
{{- if .Values.credentials.enabled }}
- name: credentials
  secret:
    secretName: {{ include "request-manager.credentialsSecretName" . }}
{{- end }}
{{- with .Values.extraVolumes }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Volume mounts shared by every application container.
*/}}
{{- define "request-manager.volumeMounts" -}}
- name: tmp
  mountPath: /tmp
{{- if .Values.credentials.enabled }}
- name: credentials
  mountPath: /app/backend/credentials
  readOnly: true
{{- end }}
{{- with .Values.extraVolumeMounts }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Container-level security context shared by every application container.
Merged as a dict so user keys override the defaults instead of being appended as duplicates.
*/}}
{{- define "request-manager.containerSecurityContext" -}}
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
{{- define "request-manager.podSecurityContext" -}}
{{- $defaults := dict
  "seccompProfile" (dict "type" "RuntimeDefault")
  "fsGroup" 65532
  "fsGroupChangePolicy" "OnRootMismatch"
-}}
{{- toYaml (mustMergeOverwrite $defaults (deepCopy (default dict .Values.podSecurityContext))) }}
{{- end }}
