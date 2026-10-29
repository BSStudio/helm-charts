# website

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Public website and video archive of Budavári Schönherz Stúdió.

**Homepage:** <https://github.com/kir-dev/bss-stack>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Budavári Schönherz Stúdió |  | <https://github.com/BSStudio/helm-charts> |

## Source Code

* <https://github.com/BSStudio/helm-charts/tree/main/charts/website>
* <https://github.com/kir-dev/bss-stack>

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | postgres | 0.20.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for the deployment |
| autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the deployment |
| autoscaling.maxReplicas | int | `10` | Sets the maximum number of application instances (replicas) that can be scaled up to during high demand |
| autoscaling.minReplicas | int | `1` | Defines the minimum number of application instances (replicas) to maintain, even during low demand |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the CPU utilization threshold at which autoscaling will be triggered to adjust the number of replicas |
| config | object | `{}` | Non-secret environment variables rendered into a ConfigMap; empty values are dropped. The app itself reads only `DATABASE_URL` (<https://github.com/kir-dev/bss-stack/blob/main/.env.example>) and the OOB config below, so this holds runtime settings. |
| existingSecret | string | `""` | Read the sensitive environment variables from an existing Secret instead of `secrets`. Its keys must be the environment variable names. DATABASE_URL below stays chart-managed. |
| extraEnv | list | `[]` | Additional environment variables, appended to the container verbatim. Prefer `config` and `secrets`; entries here take precedence over both. |
| extraEnvFrom | list | `[]` | Additional envFrom sources appended to the container |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the containers |
| extraVolumes | list | `[]` | Additional volumes to mount to the deployment |
| fullnameOverride | string | `""` | String to fully override `"website.fullname"` |
| image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| image.repository | string | `"ghcr.io/kir-dev/bss-stack"` | The Docker repository to pull the image from |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Secrets for pulling the image from a private registry |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource |
| ingress.hosts | list | `[]` | List of ingress hosts. The OIDC redirect URI is built from the request's host, so register `https://<host>/api/auth/callback` for each one. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to the deployment |
| lifecycle | object | `{}` | Container lifecycle hooks. A `preStop` sleep holds the pod open until its endpoint removal has propagated, and is charged against `terminationGracePeriodSeconds`. |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health/live","port":"http"},"periodSeconds":10}` | Liveness probe for the container. `/health/live` answers without touching the database. |
| nameOverride | string | `""` | Provide a name in place of `website` |
| nodeSelector | object | `{}` | NodeSelector for the deployment |
| oobConfig.config | object | Authentik login with the studio's group names, media from v.bsstudio.hu | BSS OOB config, rendered as JSON and mounted at `/app/oob/config.json`. Format: <https://github.com/kir-dev/bss-stack/blob/main/docs/oob-inputs.md>. With an empty client ID or secret the app rejects the whole config: nobody can log in, and video media URLs cannot be built. |
| oobConfig.existingSecret | string | `""` | Use an existing Secret holding the OOB config under the key `config.json` instead of creating one from `oobConfig.config` |
| pdb.enabled | bool | `false` | Enable a PodDisruptionBudget. With a single replica `minAvailable: 1` blocks node drains. |
| pdb.maxUnavailable | string | `""` | Maximum unavailable pods (takes precedence over minAvailable when set) |
| pdb.minAvailable | string | `""` | Minimum available pods (used when maxUnavailable is unset; defaults to 1) |
| podAnnotations | object | `{}` | Optional additional annotations to add to the pods |
| podLabels | object | `{}` | Optional additional labels to add to the pods |
| podSecurityContext | object | `{}` | Pod-level security context, merged over chart defaults (seccompProfile RuntimeDefault) |
| postgres.auth.database | string | `"website"` | Name for a custom database to create |
| postgres.auth.password | string | `""` | Password for the custom user. Required, and must be URL-safe: it is interpolated into `secrets.DATABASE_URL`. |
| postgres.auth.username | string | `"website"` | Name for a custom user to create |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health/ready","port":"http"},"periodSeconds":10}` | Readiness probe for the container. `/health/ready` returns 503 until the database is reachable and the startup migrations have finished. |
| replicaCount | int | `1` | The number of replicas to deploy (ignored when autoscaling is enabled) |
| resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"256Mi"` | The maximum amount of memory the container can use |
| resources.requests.cpu | string | `"50m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| resources.requests.memory | string | `"256Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| secrets | object | `{}` | Sensitive environment variables rendered into a Secret. DATABASE_URL defaults to the bundled sub-chart; set it to point at an external database. |
| securityContext | object | `{}` | Run containers as a specific securityContext, merged over chart defaults (runAsUser 65532; readOnlyRootFilesystem; capabilities drop ALL) |
| service.port | int | `3000` | Port number for web traffic (passed to the container as `PORT`) |
| service.type | string | `"ClusterIP"` | Kubernetes service type for web traffic |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| startupProbe | object | `{}` | Startup probe for the container. None by default: the server listens within a second, and migrations run behind the readiness probe. |
| strategy | object | `{}` | Deployment update strategy. Empty uses Kubernetes' default RollingUpdate: the new pod migrates the database while the old one still serves on the previous schema. |
| terminationGracePeriodSeconds | int | `10` | Grace period for shutdown. Must exceed the server's drain timeout: 5s, or `config.SERVER_SHUTDOWN_TIMEOUT` seconds when set. |
| tolerations | list | `[]` | Tolerations for the deployment |
