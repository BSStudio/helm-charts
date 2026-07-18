# request-manager

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.1](https://img.shields.io/badge/AppVersion-1.3.1-informational?style=flat-square)

Manage video shooting and live streaming requests at Budavári Schönherz Stúdió.

**Homepage:** <https://github.com/KOliver94/bss-request-manager>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Budavári Schönherz Stúdió |  | <https://github.com/BSStudio/helm-charts> |

## Source Code

* <https://github.com/BSStudio/helm-charts/tree/main/charts/request-manager>
* <https://github.com/KOliver94/bss-request-manager>

## Requirements

Kubernetes: `>=1.19.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | postgres | 0.19.6 |
| oci://registry-1.docker.io/cloudpirates | redis | 0.30.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for all workloads |
| beat.args | list | `["celery","-A","core","beat"]` | Container args for the Celery beat scheduler |
| beat.livenessProbe | object | `{}` | Liveness probe for the beat container (disabled by default) |
| beat.resources.limits.cpu | string | `"250m"` | The maximum amount of CPU the container can use |
| beat.resources.limits.memory | string | `"384Mi"` | The maximum amount of memory the container can use |
| beat.resources.requests.cpu | string | `"50m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| beat.resources.requests.memory | string | `"384Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| beat.terminationGracePeriodSeconds | int | `30` | Grace period for the beat scheduler to shut down |
| config | object | `{"ALLOWED_HOSTS":"","DJANGO_SETTINGS_MODULE":"core.settings.production"}` | Non-secret environment variables rendered into a ConfigMap, shared by all roles. Keys are the literal names from <https://github.com/KOliver94/bss-request-manager/blob/main/backend/.env.sample>. Connection settings (DATABASE_*, CACHE_REDIS, CELERY_BROKER) default to the bundled sub-charts. |
| config.ALLOWED_HOSTS | string | `""` | Comma separated list of allowed hosts. Must include your ingress host(s). |
| credentials.enabled | bool | `false` | Mount a Google service account key file into the credentials directory. Required only if the Google Calendar integration is used. |
| credentials.existingSecret | string | `""` | Use an existing Secret holding the key file instead of creating one from `serviceAccountKey` |
| credentials.fileName | string | `"service-account-key-file.json"` | File name of the key inside the credentials directory (env GOOGLE_SERVICE_ACCOUNT_KEY_FILE_NAME) |
| credentials.serviceAccountKey | string | `""` | Contents of the Google service account JSON key. Ignored when `existingSecret` is set. |
| existingSecret | string | `""` | Supply the sensitive environment variables from an existing Secret instead of `secrets`. The Secret's keys must match the expected environment variable names. |
| extraEnvFrom | list | `[]` | Additional envFrom sources appended to every container |
| extraVolumeMounts | list | `[]` | Additional volume mounts added to every container |
| extraVolumes | list | `[]` | Additional volumes added to every pod |
| fullnameOverride | string | `""` | String to fully override `"request-manager.fullname"` |
| image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| image.repository | string | `"ghcr.io/koliver94/bss-request-manager"` | The Docker repository to pull the image from |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets for the (private) container registry |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource for the server Service |
| ingress.hosts | list | `[]` | List of ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to every deployment |
| migrations.activeDeadlineSeconds | string | `""` | Hard time limit for the migration Job. Unset so a long migration is never killed midway. |
| migrations.args | list | `["python","manage.py","migrate"]` | Container args for the migration Job |
| migrations.backoffLimit | int | `3` | Number of retries before the migration Job is marked failed |
| migrations.enabled | bool | `true` | Run database migrations from a dedicated Job on install and upgrade. One pod migrates, so the server can scale past a single replica. Disable to migrate out-of-band; the chart assumes it is the only migrator, `manage.py migrate` is not locked. |
| migrations.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| migrations.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| migrations.resources.requests.cpu | string | `"100m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| migrations.resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| migrations.ttlSecondsAfterFinished | int | `600` | How long a finished migration Job is retained before automatic cleanup |
| migrations.waitForMigrations | bool | `true` | Block every pod in an initContainer until migrations are applied. Deliberately not in the readiness probe: that would flip healthy running pods to NotReady whenever new migrations ship. |
| migrations.waitTimeout | int | `300` | Seconds the initContainer waits for migrations before failing (the pod then retries) |
| nameOverride | string | `""` | Provide a name in place of `request-manager` |
| nodeSelector | object | `{}` | NodeSelector for all workloads |
| podAnnotations | object | `{}` | Optional additional annotations to add to all pods |
| podLabels | object | `{}` | Optional additional labels to add to all pods |
| podSecurityContext | object | `{}` | Pod-level security context, merged over chart defaults (fsGroup 65532 for volume writes) |
| postgres.auth.database | string | `"request_manager_db"` | Name for a custom database to create (also used as DATABASE_NAME) |
| postgres.auth.password | string | `""` | Password for the custom user (also used as DATABASE_PASSWORD). Must be set. |
| postgres.auth.username | string | `"request_manager"` | Name for a custom user to create (also used as DATABASE_USER) |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"1Gi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"256Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| redis.auth.enabled | bool | `false` | Enable password authentication |
| redis.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| redis.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| redis.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| redis.enabled | bool | `true` | Enable the CloudPirates Redis® chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/redis> for possible values. |
| redis.resources.limits.cpu | string | `"150m"` | The maximum amount of CPU the container can use |
| redis.resources.limits.memory | string | `"256Mi"` | The maximum amount of memory the container can use |
| redis.resources.requests.cpu | string | `"50m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| redis.resources.requests.memory | string | `"128Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| secrets | object | `{"APP_SECRET_KEY":""}` | Sensitive environment variables rendered into a Secret, shared by all roles. Keys are the literal names from <https://github.com/KOliver94/bss-request-manager/blob/main/backend/.env.sample>. With postgres.enabled, DATABASE_PASSWORD defaults to postgres.auth.password. |
| secrets.APP_SECRET_KEY | string | `""` | Django secret key. Generate with `openssl rand -base64 48`. |
| securityContext | object | `{}` | Container-level security context, merged over the hardened chart defaults |
| server.args | list | `["gunicorn","--bind=0.0.0.0:8000","--workers=2","--threads=4","--timeout=60","--graceful-timeout=30","--max-requests=1000","--max-requests-jitter=100","core.wsgi"]` | Container args (passed to the image entrypoint). Overrides the default Gunicorn command. |
| server.autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the server deployment |
| server.autoscaling.maxReplicas | int | `10` | Maximum number of server replicas |
| server.autoscaling.minReplicas | int | `1` | Minimum number of server replicas |
| server.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage that triggers scaling |
| server.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/livez","port":"http"},"initialDelaySeconds":10,"periodSeconds":10}` | Liveness probe for the server container |
| server.pdb.enabled | bool | `false` | Enable a PodDisruptionBudget for the server deployment |
| server.pdb.maxUnavailable | string | `""` | Maximum unavailable server pods (takes precedence over minAvailable when set) |
| server.pdb.minAvailable | string | `""` | Minimum available server pods (used when maxUnavailable is unset; defaults to 1) |
| server.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/readyz","port":"http"},"initialDelaySeconds":10,"periodSeconds":10}` | Readiness probe for the server container |
| server.replicaCount | int | `1` | Number of Gunicorn server replicas (ignored when autoscaling is enabled) |
| server.resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| server.resources.limits.memory | string | `"768Mi"` | The maximum amount of memory the container can use. Memory is incompressible, so this matches the request to keep the pod out of the early-eviction path. |
| server.resources.requests.cpu | string | `"500m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| server.resources.requests.memory | string | `"768Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| server.service.port | int | `8000` | Port number for HTTP traffic (the container listens on this port too) |
| server.service.type | string | `"ClusterIP"` | Kubernetes service type for HTTP traffic |
| server.startupProbe | object | `{"failureThreshold":30,"httpGet":{"path":"/livez","port":"http"},"initialDelaySeconds":10,"periodSeconds":10}` | Startup probe for the server container |
| server.strategy | object | `{}` | Deployment update strategy for the server workload |
| server.terminationGracePeriodSeconds | int | `30` | Grace period for the server pod to finish in-flight requests on shutdown |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations for all workloads |
| worker.args | list | `["celery","-A","core","worker","--concurrency=2"]` | Container args for the Celery worker. Keep `--concurrency` in step with the CPU limit; without it Celery forks one process per node CPU, which will not fit the memory limit. |
| worker.autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the worker deployment |
| worker.autoscaling.maxReplicas | int | `10` | Maximum number of worker replicas |
| worker.autoscaling.minReplicas | int | `1` | Minimum number of worker replicas |
| worker.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage that triggers scaling |
| worker.livenessProbe | object | `{"exec":{"command":["sh","-c","celery -A core inspect ping -d celery@$HOSTNAME"]},"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":10}` | Liveness probe for the worker container |
| worker.pdb.enabled | bool | `false` | Enable a PodDisruptionBudget for the worker deployment |
| worker.pdb.maxUnavailable | string | `""` | Maximum unavailable worker pods (takes precedence over minAvailable when set) |
| worker.pdb.minAvailable | string | `""` | Minimum available worker pods (used when maxUnavailable is unset; defaults to 1) |
| worker.readinessProbe | object | `{"exec":{"command":["sh","-c","celery -A core inspect ping -d celery@$HOSTNAME"]},"failureThreshold":3,"initialDelaySeconds":15,"periodSeconds":30,"timeoutSeconds":10}` | Readiness probe for the worker container |
| worker.replicaCount | int | `1` | Number of Celery worker replicas (ignored when autoscaling is enabled) |
| worker.resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| worker.resources.limits.memory | string | `"768Mi"` | The maximum amount of memory the container can use |
| worker.resources.requests.cpu | string | `"500m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| worker.resources.requests.memory | string | `"768Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| worker.terminationGracePeriodSeconds | int | `60` | Grace period for the worker to finish in-flight tasks on shutdown |
