# outline

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.8.1](https://img.shields.io/badge/AppVersion-1.8.1-informational?style=flat-square)

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

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | minio | 0.13.0 |
| oci://registry-1.docker.io/cloudpirates | postgres | 0.19.6 |
| oci://registry-1.docker.io/cloudpirates | redis | 0.30.6 |

## Upgrading

### 1.x to 2.0

The `outline` values block is replaced by `config` (rendered into a ConfigMap) and `secrets`
(rendered into a Secret). Keys are now the literal environment variable names from Outline's
[.env.sample](https://github.com/outline/outline/blob/main/.env.sample), so `outline.secret_key`
becomes `secrets.SECRET_KEY`, and a nested `outline.smtp.host` becomes `config.SMTP_HOST`.

```yaml
# before
outline:
  secret_key: "..."
  utils_secret: "..."
  url: https://wiki.example.com
  database_url: postgres://outline:hunter2@outline-postgres:5432/outline

# after
config:
  URL: https://wiki.example.com
secrets:
  SECRET_KEY: "..."
  UTILS_SECRET: "..."
```

`DATABASE_URL` and `REDIS_URL` no longer need to be set when the bundled sub-charts are used: they
are built from `postgres.auth` and the release name. Set `postgres.auth.password` instead, which
previously had to be kept in sync with the password embedded in `outline.database_url`. Set
`secrets.DATABASE_URL` explicitly only to point at an external database.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for the deployment |
| autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled or disabled for the application |
| autoscaling.maxReplicas | int | `100` | Sets the maximum number of application instances (replicas) that can be scaled up to during high demand |
| autoscaling.minReplicas | int | `1` | Defines the minimum number of application instances (replicas) to maintain, even during low demand |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the CPU utilization threshold at which autoscaling will be triggered to adjust the number of replicas |
| config | object | `{"FILE_STORAGE":"local","FILE_STORAGE_UPLOAD_MAX_SIZE":"50000000","FORCE_HTTPS":"false","PGSSLMODE":"disable","URL":"https://outline.example.com"}` | Non-secret environment variables rendered into a ConfigMap. Keys are the literal names from <https://github.com/outline/outline/blob/main/.env.sample>. |
| config.FILE_STORAGE | string | `"local"` | Storage system to use, either "s3" or "local" |
| config.FILE_STORAGE_UPLOAD_MAX_SIZE | string | `"50000000"` | Maximum allowed byte size for an uploaded attachment. Must be a string. |
| config.FORCE_HTTPS | string | `"false"` | Redirect HTTP to HTTPS in the application. Leave false when TLS is terminated by the ingress. |
| config.PGSSLMODE | string | `"disable"` | SSL mode for connecting to PostgreSQL |
| config.URL | string | `"https://outline.example.com"` | Fully qualified, publicly accessible URL |
| env | list | `[]` | Additional environment variables, appended to the container verbatim. Prefer `config` and `secrets`; entries here take precedence over both. |
| envFrom | list | `[]` | envFrom to pass to the deployment |
| existingSecret | string | `""` | Read the sensitive environment variables from an existing Secret instead of `secrets`. Its keys must be the environment variable names. The connection strings below are still chart-managed. |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the containers |
| extraVolumes | list | `[]` | Additional volumes to mount to the deployment |
| fullnameOverride | string | `""` | String to fully override `"outline.fullname"` |
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
| nameOverride | string | `""` | Provide a name in place of `outline` |
| nodeSelector | object | `{}` | NodeSelector for the deployment |
| pdb.enabled | bool | `false` | Enable a PodDisruptionBudget. With a single replica `minAvailable: 1` blocks node drains. |
| pdb.maxUnavailable | string | `""` | Maximum unavailable pods (takes precedence over minAvailable when set) |
| pdb.minAvailable | string | `""` | Minimum available pods (used when maxUnavailable is unset; defaults to 1) |
| persistence.accessMode | string | `"ReadWriteOnce"` | Specifies the level of access to the persistent storage (e.g., read-write, read-only) |
| persistence.annotations | object | `{}` | Annotations to add to the PVC, e.g. `helm.sh/resource-policy: keep` to retain data on uninstall |
| persistence.enabled | bool | `true` | Determines whether persistent storage is enabled or not |
| persistence.size | string | `"2Gi"` | Defines the amount of storage allocated for persistence |
| podAnnotations | object | `{}` | Optional additional annotations to add to the pods |
| podLabels | object | `{}` | Optional additional labels to add to the pods |
| podSecurityContext | object | `{}` | Pod-level security context, merged over chart defaults (fsGroup 65534 for volume writes) |
| postgres.auth.database | string | `"outline"` | Name for a custom database to create |
| postgres.auth.password | string | `""` | Password for the custom user. Required, and must be URL-safe: it is interpolated into `outline.database_url`. |
| postgres.auth.username | string | `"outline"` | Name for a custom user to create |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| redis.auth.enabled | bool | `false` | Enable password authentication |
| redis.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| redis.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| redis.enabled | bool | `true` | Enable the CloudPirates Redis® chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/redis> for possible values. |
| redis.resources.limits.cpu | string | `"150m"` | The maximum amount of CPU the container can use |
| redis.resources.limits.memory | string | `"256Mi"` | The maximum amount of memory the container can use |
| redis.resources.requests.cpu | string | `"50m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| redis.resources.requests.memory | string | `"256Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| replicaCount | int | `1` | The number of replicas to deploy |
| resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"1Gi"` | The maximum amount of memory the container can use |
| resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| resources.requests.memory | string | `"1Gi"` | Specifies the minimum amount of memory that will be allocated to the container |
| scheduler.activeDeadlineSeconds | int | `300` | Hard time limit for a single run before it is killed (guards against a hung request) |
| scheduler.annotations | object | `{}` | Optional additional annotations to add to the CronJob runner pod |
| scheduler.backoffLimit | int | `1` | Number of retries before a run is marked failed |
| scheduler.concurrencyPolicy | string | `"Forbid"` | Concurrency policy for the CronJob |
| scheduler.enabled | bool | `true` | Create a CronJob to run Outline's scheduled jobs. Refer to <https://docs.getoutline.com/s/hosting/doc/scheduled-jobs-RhZzCt770H> for more information. |
| scheduler.failedJobsHistoryLimit | int | `3` | How many failed jobs to retain for debugging |
| scheduler.labels | object | `{}` | Optional additional labels to add to the CronJob runner pod |
| scheduler.podSecurityContext | object | `{}` | Pod-level security context for the runner pod, merged over the chart defaults |
| scheduler.schedule | string | `"30 12 * * *"` | Schedule to use for the CronJob |
| scheduler.securityContext | object | `{}` | Container-level security context for the runner container, merged over the chart defaults |
| scheduler.successfulJobsHistoryLimit | int | `3` | How many completed jobs to retain |
| scheduler.timeZone | string | `"Europe/Budapest"` | Timezone for interpreting the cron schedule |
| secrets | object | `{"SECRET_KEY":"","UTILS_SECRET":""}` | Sensitive environment variables rendered into a Secret. Keys are the literal names from <https://github.com/outline/outline/blob/main/.env.sample>. DATABASE_URL and REDIS_URL default to the bundled sub-charts; set them to point at an external database or cache. |
| secrets.SECRET_KEY | string | `""` | Hex-encoded 32-byte random key. Generate with `openssl rand -hex 32`. |
| secrets.UTILS_SECRET | string | `""` | Unique random key. Generate with `openssl rand -hex 32`. |
| securityContext | object | `{}` | Run containers as a specific securityContext |
| service.port | int | `3000` | Port number for web traffic |
| service.type | string | `"ClusterIP"` | Kubernetes service type for web traffic |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| strategy | object | `{}` | Deployment update strategy. When empty, defaults to `Recreate` if persistence is enabled with a non-`ReadWriteMany` access mode (avoids a RWO volume deadlock on upgrade), otherwise Kubernetes' default RollingUpdate is used. |
| terminationGracePeriodSeconds | int | `75` | Grace period for shutdown. Above Outline's own 60s force-quit timeout, so it is not killed mid-drain. |
| tolerations | list | `[]` | Tolerations for the deployment |
