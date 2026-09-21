# raktr

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Inventory and rental management system for Budavári Schönherz Stúdió.

**Homepage:** <https://github.com/mboldi/Raktr>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Budavári Schönherz Stúdió |  | <https://github.com/BSStudio/helm-charts> |

## Source Code

* <https://github.com/BSStudio/helm-charts/tree/main/charts/raktr>
* <https://github.com/mboldi/Raktr>

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | postgres | 0.20.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for all workloads |
| backend.autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the backend deployment |
| backend.autoscaling.maxReplicas | int | `10` | Maximum number of backend replicas |
| backend.autoscaling.minReplicas | int | `1` | Minimum number of backend replicas |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage that triggers scaling |
| backend.image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| backend.image.repository | string | `"ghcr.io/mboldi/raktr/backend"` | The Docker repository to pull the backend image from |
| backend.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| backend.lifecycle | object | `{}` | Container lifecycle hooks. A `preStop` sleep holds the pod open until its endpoint removal has propagated, and is charged against `terminationGracePeriodSeconds`. |
| backend.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"tcpSocket":{"port":"http"}}` | Liveness probe for the backend container. `tcpSocket`: `/api/actuator/health` queries the database, and the actuator's liveness group is behind authentication. |
| backend.pdb.enabled | bool | `false` | Enable a PodDisruptionBudget for the backend. With a single replica `minAvailable: 1` blocks node drains. |
| backend.pdb.maxUnavailable | string | `""` | Maximum unavailable backend pods (takes precedence over minAvailable when set) |
| backend.pdb.minAvailable | string | `""` | Minimum available backend pods (used when maxUnavailable is unset; defaults to 1) |
| backend.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/api/actuator/health","port":"http"},"periodSeconds":10}` | Readiness probe for the backend container |
| backend.replicaCount | int | `1` | Number of backend replicas (ignored when autoscaling is enabled). Flyway migrates on startup under a database lock, so replicas can start together. |
| backend.resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| backend.resources.limits.memory | string | `"768Mi"` | The maximum amount of memory the container can use. Keep `config.JAVA_TOOL_OPTIONS` in step: the heap is sized from this limit. |
| backend.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| backend.resources.requests.memory | string | `"768Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| backend.service.port | int | `8080` | Port number for the API |
| backend.service.type | string | `"ClusterIP"` | Kubernetes service type for the API |
| backend.startupProbe | object | `{"failureThreshold":60,"httpGet":{"path":"/api/actuator/health","port":"http"},"initialDelaySeconds":10,"periodSeconds":5}` | Startup probe for the backend container. Flyway migrates before the port opens, so the window has to cover the migrations as well as the JVM start. |
| backend.strategy | object | `{}` | Deployment update strategy for the backend |
| backend.terminationGracePeriodSeconds | int | `45` | Grace period for shutdown. Above the 30s Spring allows its graceful shutdown to drain requests. |
| config | object | `{"JAVA_TOOL_OPTIONS":"-XX:MaxRAMPercentage=50","SPRING_PROFILES_ACTIVE":"prod"}` | Non-secret environment variables for the backend, rendered into a ConfigMap. Keys are the environment forms of the Spring properties in <https://github.com/mboldi/Raktr/blob/main/backend/src/main/resources/application.yml>; empty values are dropped. With postgres.enabled, SPRING_DATASOURCE_URL and _USERNAME default to it. |
| config.JAVA_TOOL_OPTIONS | string | `"-XX:MaxRAMPercentage=50"` | JVM flags. The JVM caps its heap at 25% of the memory limit unless told otherwise. |
| config.SPRING_PROFILES_ACTIVE | string | `"prod"` | `prod` turns off the Swagger UI and the API docs |
| existingSecret | string | `""` | Supply the sensitive environment variables from an existing Secret instead of `secrets`. Its keys must be the environment variable names. SPRING_DATASOURCE_PASSWORD stays chart-managed. |
| extraEnv | list | `[]` | Additional environment variables, appended to the backend container verbatim. Prefer `config` and `secrets`; entries here take precedence over both. |
| extraEnvFrom | list | `[]` | Additional envFrom sources appended to the backend container |
| extraVolumeMounts | list | `[]` | Additional volume mounts added to the backend container |
| extraVolumes | list | `[]` | Additional volumes added to the backend pod |
| frontend.autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the frontend deployment |
| frontend.autoscaling.maxReplicas | int | `10` | Maximum number of frontend replicas |
| frontend.autoscaling.minReplicas | int | `1` | Minimum number of frontend replicas |
| frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage that triggers scaling |
| frontend.image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| frontend.image.repository | string | `"ghcr.io/mboldi/raktr/frontend"` | The Docker repository to pull the frontend image from |
| frontend.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| frontend.lifecycle | object | `{}` | Container lifecycle hooks |
| frontend.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":10}` | Liveness probe for the frontend container |
| frontend.pdb.enabled | bool | `false` | Enable a PodDisruptionBudget for the frontend. With a single replica `minAvailable: 1` blocks node drains. |
| frontend.pdb.maxUnavailable | string | `""` | Maximum unavailable frontend pods (takes precedence over minAvailable when set) |
| frontend.pdb.minAvailable | string | `""` | Minimum available frontend pods (used when maxUnavailable is unset; defaults to 1) |
| frontend.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":10}` | Readiness probe for the frontend container |
| frontend.replicaCount | int | `1` | Number of frontend replicas (ignored when autoscaling is enabled) |
| frontend.resources.limits.cpu | string | `"250m"` | The maximum amount of CPU the container can use |
| frontend.resources.limits.memory | string | `"64Mi"` | The maximum amount of memory the container can use. nginx starts one worker per node CPU. |
| frontend.resources.requests.cpu | string | `"25m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| frontend.resources.requests.memory | string | `"64Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| frontend.service.port | int | `8080` | Port number for the web app |
| frontend.service.type | string | `"ClusterIP"` | Kubernetes service type for the web app |
| frontend.startupProbe | object | `{}` | Startup probe for the frontend container (disabled by default; nginx starts in under a second) |
| frontend.strategy | object | `{}` | Deployment update strategy for the frontend |
| frontend.terminationGracePeriodSeconds | int | `30` | Grace period for shutdown. nginx drains open connections on the image's `SIGQUIT` stop signal. |
| fullnameOverride | string | `""` | String to fully override `"raktr.fullname"` |
| imagePullSecrets | list | `[]` | Secrets for pulling the images from a private registry |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource. The frontend calls the API on its own origin, so each host routes `/api` to the backend, which the chart serves under that context path, and the rest to the frontend. |
| ingress.hosts | list | `[]` | List of ingress hosts. The paths are fixed by the chart. The frontend image hardcodes its Authentik client and sends the user back to its own origin, so each host has to be a redirect URI of that client. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to the backend deployment |
| nameOverride | string | `""` | Provide a name in place of `raktr` |
| nodeSelector | object | `{}` | NodeSelector for all workloads |
| podAnnotations | object | `{}` | Optional additional annotations to add to all pods |
| podLabels | object | `{}` | Optional additional labels to add to all pods |
| podSecurityContext | object | `{}` | Pod-level security context, merged over chart defaults (fsGroup 65532 for volume writes) |
| postgres.auth.database | string | `"raktr"` | Name for a custom database to create (used in SPRING_DATASOURCE_URL) |
| postgres.auth.password | string | `""` | Password for the custom user (also used as SPRING_DATASOURCE_PASSWORD). Must be set. |
| postgres.auth.username | string | `"raktr"` | Name for a custom user to create (also used as SPRING_DATASOURCE_USERNAME) |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| secrets | object | `{"SENTRY_DSN":""}` | Sensitive environment variables for the backend, rendered into a Secret. Keys follow the same scheme as `config`. With postgres.enabled, SPRING_DATASOURCE_PASSWORD defaults to postgres.auth.password. |
| secrets.SENTRY_DSN | string | `""` | Sentry DSN for error reporting. Empty disables Sentry. |
| securityContext | object | `{}` | Container-level security context for both workloads, merged over the hardened chart defaults (runAsUser 65532, readOnlyRootFilesystem, capabilities drop ALL) |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations for all workloads |
