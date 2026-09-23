# raktr

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.1](https://img.shields.io/badge/AppVersion-1.3.1-informational?style=flat-square)

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

## Upgrading

### 0.1.x to 0.2.0

The backend's application settings move under `backend`, where the frontend already keeps its own.
`config`, `secrets`, `existingSecret`, `extraEnv`, `extraEnvFrom`, `extraVolumes`, `extraVolumeMounts`
and `initContainers` move as they are; only their place changes.

```yaml
# before
config:
  SPRING_DATASOURCE_URL: jdbc:postgresql://db.example.com:5432/raktr
existingSecret: raktr-env

# after
backend:
  config:
    SPRING_DATASOURCE_URL: jdbc:postgresql://db.example.com:5432/raktr
  existingSecret: raktr-env
```

A key left at the top level is read by nothing and the chart default takes over. That is loud for an
external `SPRING_DATASOURCE_URL` — the backend falls back to `localhost:5432` and exits — and quiet
for `secrets` and `existingSecret`, where the pods come up with the feature switched off.

The backend's ConfigMap and Secret are renamed to `<release>-backend`, so anything outside the chart
that reads them by name needs the new one.

Sentry in the browser arrives with this release, off until you set it:

```yaml
frontend:
  config:
    SENTRY_DSN: https://examplePublicKey@o0.ingest.sentry.io/0
    SENTRY_ENVIRONMENT: production
```

The frontend now serves the site from an emptyDir that an init container fills, because images with
that support rewrite `config.js` at startup and the root filesystem is read-only. Older images are
served the same way, so the upgrade needs nothing from you either way.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for all workloads |
| backend.autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the backend deployment |
| backend.autoscaling.maxReplicas | int | `10` | Maximum number of backend replicas |
| backend.autoscaling.minReplicas | int | `1` | Minimum number of backend replicas |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage that triggers scaling |
| backend.config | object | `{"JAVA_TOOL_OPTIONS":"-XX:MaxRAMPercentage=50","SPRING_PROFILES_ACTIVE":"prod"}` | Non-secret environment variables for the backend; empty values are dropped. Keys are the environment forms of the properties in <https://github.com/mboldi/Raktr/blob/main/backend/src/main/resources/application.yml>. With postgres.enabled, SPRING_DATASOURCE_URL and _USERNAME default to it. |
| backend.config.JAVA_TOOL_OPTIONS | string | `"-XX:MaxRAMPercentage=50"` | JVM flags. The heap defaults to 25% of the memory limit. |
| backend.config.SPRING_PROFILES_ACTIVE | string | `"prod"` | `prod` turns off the Swagger UI and the API docs |
| backend.existingSecret | string | `""` | Supply the sensitive environment variables from an existing Secret instead of `secrets`. Its keys must be the environment variable names. SPRING_DATASOURCE_PASSWORD stays chart-managed. |
| backend.extraEnv | list | `[]` | Additional environment variables for the backend container. These win over `config` and `secrets`. |
| backend.extraEnvFrom | list | `[]` | Additional envFrom sources appended to the backend container |
| backend.extraVolumeMounts | list | `[]` | Additional volume mounts added to the backend container |
| backend.extraVolumes | list | `[]` | Additional volumes added to the backend pod |
| backend.image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| backend.image.repository | string | `"ghcr.io/mboldi/raktr/backend"` | The Docker repository to pull the backend image from |
| backend.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| backend.initContainers | list | `[]` | Init containers to add to the backend deployment |
| backend.lifecycle | object | `{}` | Container lifecycle hooks. A `preStop` sleep is charged against `terminationGracePeriodSeconds`. |
| backend.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"tcpSocket":{"port":"http"}}` | Liveness probe. The health endpoint queries the database, and the probe groups need a token. |
| backend.pdb.enabled | bool | `false` | Enable a PodDisruptionBudget for the backend. `minAvailable: 1` blocks drains at one replica. |
| backend.pdb.maxUnavailable | string | `""` | Maximum unavailable backend pods (takes precedence over minAvailable when set) |
| backend.pdb.minAvailable | string | `""` | Minimum available backend pods (used when maxUnavailable is unset; defaults to 1) |
| backend.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/api/actuator/health","port":"http"},"periodSeconds":10}` | Readiness probe for the backend container |
| backend.replicaCount | int | `1` | Number of backend replicas (ignored when autoscaling is enabled) |
| backend.resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| backend.resources.limits.memory | string | `"768Mi"` | The maximum amount of memory the container can use |
| backend.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| backend.resources.requests.memory | string | `"768Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| backend.secrets | object | `{"SENTRY_DSN":""}` | Sensitive environment variables for the backend. Keys follow the same scheme as `config`. With postgres.enabled, SPRING_DATASOURCE_PASSWORD defaults to postgres.auth.password. |
| backend.secrets.SENTRY_DSN | string | `""` | Sentry DSN for error reporting. Empty disables Sentry. |
| backend.service.port | int | `8080` | Port number for the API |
| backend.service.type | string | `"ClusterIP"` | Kubernetes service type for the API |
| backend.startupProbe | object | `{"failureThreshold":60,"httpGet":{"path":"/api/actuator/health","port":"http"},"initialDelaySeconds":10,"periodSeconds":5}` | Startup probe. Flyway migrates before the port opens. |
| backend.strategy | object | `{}` | Deployment update strategy for the backend |
| backend.terminationGracePeriodSeconds | int | `45` | Grace period for shutdown. Spring's graceful shutdown drains for up to 30s. |
| frontend.autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the frontend deployment |
| frontend.autoscaling.maxReplicas | int | `10` | Maximum number of frontend replicas |
| frontend.autoscaling.minReplicas | int | `1` | Minimum number of frontend replicas |
| frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage that triggers scaling |
| frontend.config | object | `{"SENTRY_DSN":"","SENTRY_ENVIRONMENT":""}` | Environment variables for the frontend, written into the browser's `config.js` at startup. Keys from <https://github.com/mboldi/Raktr/blob/main/frontend/nginx/40-sentry-config.sh>, except RAKTR_RELEASE: the image carries the release its source maps were uploaded for. |
| frontend.config.SENTRY_DSN | string | `""` | Sentry DSN for browser error reporting. Empty disables Sentry. |
| frontend.config.SENTRY_ENVIRONMENT | string | `""` | Environment tag on the browser's Sentry events. Empty means `production`. |
| frontend.image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| frontend.image.repository | string | `"ghcr.io/mboldi/raktr/frontend"` | The Docker repository to pull the frontend image from |
| frontend.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| frontend.lifecycle | object | `{}` | Container lifecycle hooks |
| frontend.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":10}` | Liveness probe for the frontend container |
| frontend.pdb.enabled | bool | `false` | Enable a PodDisruptionBudget for the frontend. `minAvailable: 1` blocks drains at one replica. |
| frontend.pdb.maxUnavailable | string | `""` | Maximum unavailable frontend pods (takes precedence over minAvailable when set) |
| frontend.pdb.minAvailable | string | `""` | Minimum available frontend pods (used when maxUnavailable is unset; defaults to 1) |
| frontend.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":10}` | Readiness probe for the frontend container |
| frontend.replicaCount | int | `1` | Number of frontend replicas (ignored when autoscaling is enabled) |
| frontend.resources.limits.cpu | string | `"250m"` | The maximum amount of CPU the container can use |
| frontend.resources.limits.memory | string | `"64Mi"` | The maximum amount of memory the container can use. nginx runs one worker per node CPU. |
| frontend.resources.requests.cpu | string | `"25m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| frontend.resources.requests.memory | string | `"64Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| frontend.service.port | int | `8080` | Port number for the web app |
| frontend.service.type | string | `"ClusterIP"` | Kubernetes service type for the web app |
| frontend.startupProbe | object | `{}` | Startup probe for the frontend container (disabled by default) |
| frontend.strategy | object | `{}` | Deployment update strategy for the frontend |
| frontend.terminationGracePeriodSeconds | int | `30` | Grace period for shutdown |
| frontend.webrootSizeLimit | string | `"64Mi"` | Size limit for the emptyDir the site is served from |
| fullnameOverride | string | `""` | String to fully override `"raktr.fullname"` |
| imagePullSecrets | list | `[]` | Secrets for pulling the images from a private registry |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource. Each host routes `/api` to the backend and the rest to the frontend. |
| ingress.hosts | list | `[]` | List of ingress hosts; the chart fixes the paths. Each host has to be a redirect URI of the Authentik client the frontend image hardcodes. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
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
| securityContext | object | `{}` | Container-level security context for both workloads, merged over the hardened chart defaults (runAsUser 65532, readOnlyRootFilesystem, capabilities drop ALL) |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations for all workloads |
