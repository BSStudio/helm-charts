# outline

![Version: 1.2.4](https://img.shields.io/badge/Version-1.2.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.1.0](https://img.shields.io/badge/AppVersion-1.1.0-informational?style=flat-square)

Outline is a fast, collaborative, knowledge base for your team built using React and Node.js.

**Homepage:** <https://www.getoutline.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Budavári Schönherz Stúdió |  | <https://github.com/BSStudio/helm-charts> |

## Source Code

* <https://github.com/BSStudio/helm-charts/tree/main/charts/outline>
* <https://github.com/outline/outline>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | minio | 0.5.6 |
| oci://registry-1.docker.io/cloudpirates | postgres | 0.12.2 |
| oci://registry-1.docker.io/cloudpirates | redis | 0.16.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for the deployment |
| autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled or disabled for the application |
| autoscaling.maxReplicas | int | `100` | Sets the maximum number of application instances (replicas) that can be scaled up to during high demand |
| autoscaling.minReplicas | int | `1` | Defines the minimum number of application instances (replicas) to maintain, even during low demand |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the CPU utilization threshold at which autoscaling will be triggered to adjust the number of replicas |
| env | list | `[]` | Environment variables to pass to the deployment See configuration options at <https://github.com/outline/outline/blob/main/.env.sample> |
| envFrom | list | `[]` | envFrom to pass to the deployment |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the containers |
| extraVolumes | list | `[]` | Additional volumes to mount to the deployment |
| fullnameOverride | string | `""` | String to fully override `"outline.fullname"`. Prefer using global.fullnameOverride if possible |
| image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| image.repository | string | `"outlinewiki/outline"` | The Docker repository to pull the image from |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource |
| ingress.hosts | list | `[]` | List of ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to the deployment |
| minio.enabled | bool | `false` | Enable the CloudPirates MinIO® chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/minio> for possible values. |
| nameOverride | string | `""` | Provide a name in place of `outline`. Prefer using global.nameOverride if possible |
| nodeSelector | object | `{}` | NodeSelector for the deployment |
| outline.database_url | string | `"postgres://outline:secretPassword@outline-postgres:5432/outline"` | Connection string to access the database |
| outline.file_storage | string | `"local"` | Specify what storage system to use. Possible value is one of "s3" or "local". |
| outline.file_storage_upload_max_size | string | `"50000000"` | Maximum allowed byte size for the uploaded attachment. Make sure to define it as a string. |
| outline.pgsslmode | string | `"disable"` | Disable SSL for connecting to PostgreSQL |
| outline.redis_url | string | `"redis://outline-redis:6379"` | Connection string to access Redis |
| outline.secret_key | string | `""` | Generate a hex-encoded 32-byte random key. You should use `openssl rand -hex 32` in your terminal to generate a random value. |
| outline.url | string | `"https://outline.example.com"` | URL should point to the fully qualified, publicly accessible URL. |
| outline.utils_secret | string | `""` | Generate a unique random key. The format is not important but you could still use `openssl rand -hex 32` in your terminal to produce this. |
| persistence.accessMode | string | `"ReadWriteOnce"` | Specifies the level of access to the persistent storage (e.g., read-write, read-only) |
| persistence.enabled | bool | `true` | Determines whether persistent storage is enabled or not |
| persistence.size | string | `"2Gi"` | Defines the amount of storage allocated for persistence |
| podAnnotations | object | `{}` | Optional additional annotations to add to the pods |
| podLabels | object | `{}` | Optional additional labels to add to the pods |
| podSecurityContext | object | `{}` |  |
| postgres.auth.database | string | `"outline"` | Name for a custom database to create |
| postgres.auth.username | string | `"outline"` | Name for a custom user to create |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"256Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| redis.auth.enabled | bool | `false` | Enable password authentication |
| redis.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| redis.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| redis.enabled | bool | `true` | Enable the CloudPirates Redis® chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/redis> for possible values. |
| redis.resources.limits.cpu | string | `"150m"` | The maximum amount of CPU the container can use |
| redis.resources.limits.memory | string | `"256Mi"` | The maximum amount of memory the container can use |
| redis.resources.requests.cpu | string | `"50m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| redis.resources.requests.memory | string | `"128Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| replicaCount | int | `1` | The number of replicas to deploy |
| resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"1Gi"` | The maximum amount of memory the container can use |
| resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| scheduler.annotations | object | `{}` | Optional additional annotations to add to the CronJob runner pod |
| scheduler.concurrencyPolicy | string | `"Forbid"` | Concurrency policy for the CronJob |
| scheduler.enabled | bool | `true` | Create a CronJob to run Outline's scheduled jobs. Refer to <https://docs.getoutline.com/s/hosting/doc/scheduled-jobs-RhZzCt770H> for more information. |
| scheduler.labels | object | `{}` | Optional additional labels to add to the CronJob runner pod |
| scheduler.schedule | string | `"30 12 * * *"` | Schedule to use for the CronJob |
| scheduler.timeZone | string | `"Europe/Budapest"` | Timezone for interpreting the cron schedule |
| securityContext | object | `{}` | Run containers as a specific securityContext |
| service.port | int | `3000` | Port number for web traffic |
| service.type | string | `"ClusterIP"` | Kubernetes service type for web traffic |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations for the deployment |
