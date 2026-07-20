# mattermost

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 11.8.1](https://img.shields.io/badge/AppVersion-11.8.1-informational?style=flat-square)

Mattermost Team Edition with OIDC single sign-on and the user limit lifted.

**Homepage:** <https://mattermost.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Budavári Schönherz Stúdió |  | <https://github.com/BSStudio/helm-charts> |

## Source Code

* <https://github.com/BSStudio/helm-charts/tree/main/charts/mattermost>
* <https://github.com/BSStudio/mattermost-image>
* <https://github.com/BSStudio/mattermost-oidc>
* <https://github.com/mattermost/mattermost>

## Requirements

Kubernetes: `>=1.21.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | postgres | 0.19.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for the deployment |
| config | object | `{"MM_FILESETTINGS_DRIVERNAME":"local","MM_SQLSETTINGS_DRIVERNAME":"postgres"}` | Non-secret environment variables rendered into a ConfigMap. Keys are the literal `MM_<SECTION>_<SETTING>` names Mattermost reads (<https://docs.mattermost.com/configure/configuration-settings.html>). Each overrides the value stored in the database; empty values are dropped. |
| config.MM_FILESETTINGS_DRIVERNAME | string | `"local"` | File storage backend, "local" or "amazons3". "local" pins the deployment to one node unless `persistence.accessMode` is ReadWriteMany. |
| config.MM_SQLSETTINGS_DRIVERNAME | string | `"postgres"` | Database driver. Only "postgres" is supported by this chart's bundled database. |
| existingSecret | string | `""` | Read the sensitive environment variables from an existing Secret instead of `secrets`. Its keys must be the environment variable names. The database connection below is still chart-managed. |
| extraEnv | list | `[]` | Additional environment variables, appended to the container verbatim. Prefer `config` and `secrets`; entries here take precedence over both. |
| extraEnvFrom | list | `[]` | Additional envFrom sources appended to the container |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the containers |
| extraVolumes | list | `[]` | Additional volumes to mount to the deployment |
| fullnameOverride | string | `""` | String to fully override `"mattermost.fullname"` |
| image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| image.repository | string | `"ghcr.io/bsstudio/mattermost-team-edition"` | The Docker repository to pull the image from. The BSStudio build is Team Edition with the OIDC patch applied and the user cap lifted (<https://github.com/BSStudio/mattermost-image>). |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Secrets for pulling the image from a private registry |
| ingress.annotations | object | `{}` | Additional ingress annotations. Mattermost pushes large uploads and long-polls, so a bigger body size and read timeout are usually needed on the controller. |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource |
| ingress.hosts | list | `[]` | List of ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to the deployment |
| livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"tcpSocket":{"port":"http"}}` | Liveness probe for the container. `tcpSocket`, not the ping endpoint: a ping that reaches the database would restart every replica during a database blip, which cannot fix it. |
| nameOverride | string | `""` | Provide a name in place of `mattermost` |
| nodeSelector | object | `{}` | NodeSelector for the deployment |
| pdb.enabled | bool | `false` | Enable a PodDisruptionBudget. With a single replica `minAvailable: 1` blocks node drains. |
| pdb.maxUnavailable | string | `""` | Maximum unavailable pods (takes precedence over minAvailable when set) |
| pdb.minAvailable | string | `""` | Minimum available pods (used when maxUnavailable is unset; defaults to 1) |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the volume. ReadWriteMany is required to run more than one replica while file storage is "local". |
| persistence.annotations | object | `{}` | Annotations to add to the PVC, e.g. `helm.sh/resource-policy: keep` to retain data on uninstall |
| persistence.enabled | bool | `true` | Persist uploaded files, attachments and plugins (`/mattermost/data`). Required with local file storage and a read-only root filesystem. |
| persistence.size | string | `"10Gi"` | Defines the amount of storage allocated for persistence |
| podAnnotations | object | `{}` | Optional additional annotations to add to the pods |
| podLabels | object | `{}` | Optional additional labels to add to the pods |
| podSecurityContext | object | `{}` | Pod-level security context, merged over chart defaults (fsGroup 65534 for volume writes) |
| postgres.auth.database | string | `"mattermost"` | Name for a custom database to create |
| postgres.auth.password | string | `""` | Password for the custom user. Required, and must be URL-safe: it is interpolated into the database connection string. |
| postgres.auth.username | string | `"mattermost"` | Name for a custom user to create |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/api/v4/system/ping","port":"http"},"initialDelaySeconds":15,"periodSeconds":10}` | Readiness probe for the container |
| replicaCount | int | `1` | The number of replicas to deploy. Scaling past one needs a `ReadWriteMany` data volume (or external S3 file storage): the bundled default is a single `ReadWriteOnce` PVC only one node can mount. |
| resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"1Gi"` | The maximum amount of memory the container can use |
| resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| resources.requests.memory | string | `"1Gi"` | Specifies the minimum amount of memory that will be allocated to the container |
| secrets | object | `{}` | Sensitive environment variables rendered into a Secret. `MM_CONFIG` and `MM_SQLSETTINGS_DATASOURCE` default to the bundled database; set them to point at an external PostgreSQL. |
| securityContext | object | `{}` | Run containers as a specific securityContext, merged over chart defaults (runAsUser 65534, readOnlyRootFilesystem, capabilities drop ALL) |
| service.port | int | `8065` | Port number for web traffic |
| service.type | string | `"ClusterIP"` | Kubernetes service type for web traffic |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| startupProbe | object | `{"failureThreshold":30,"httpGet":{"path":"/api/v4/system/ping","port":"http"},"initialDelaySeconds":10,"periodSeconds":10}` | Startup probe for the container. Generous threshold: the first boot runs database migrations. |
| strategy | object | `{}` | Deployment update strategy. When empty, defaults to `Recreate` if persistence is enabled with a non-`ReadWriteMany` access mode (avoids a RWO volume deadlock on upgrade), otherwise Kubernetes' default RollingUpdate is used. |
| terminationGracePeriodSeconds | int | `60` | Grace period for shutdown. Should exceed Mattermost's own graceful-shutdown timeout so it is not killed mid-drain. |
| tolerations | list | `[]` | Tolerations for the deployment |
