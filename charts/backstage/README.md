# backstage

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.1.0](https://img.shields.io/badge/AppVersion-1.1.0-informational?style=flat-square)

Internal member portal for Budavári Schönherz Stúdió, and the source of truth for member data.

**Homepage:** <https://github.com/BSStudio/backstage>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Budavári Schönherz Stúdió |  | <https://github.com/BSStudio/helm-charts> |

## Source Code

* <https://github.com/BSStudio/helm-charts/tree/main/charts/backstage>
* <https://github.com/BSStudio/backstage>

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/cloudpirates | postgres | 0.20.4 |

## Upgrading

### 0.3.x to 0.4.0

Application 1.1.0 adds the Google Group sync and the calendar dashboard, which read four new
settings: `secrets.GOOGLE_SERVICE_ACCOUNT_KEY`, `config.GOOGLE_GROUP_EMAIL`,
`config.GOOGLE_ALUMNI_GROUP_EMAIL` and `config.GOOGLE_CALENDAR_ID`. Leaving them empty is a
supported state — the Google sync jobs record themselves as `SKIPPED` and the dashboard drops the
calendar widget — so the upgrade can land before the credentials exist.

```yaml
config:
  GOOGLE_GROUP_EMAIL: members@example.com
  GOOGLE_ALUMNI_GROUP_EMAIL: alumni@example.com
  GOOGLE_CALENDAR_ID: studio@group.calendar.google.com
secrets:
  # base64 of the downloaded service account JSON key
  GOOGLE_SERVICE_ACCOUNT_KEY: "eyJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsIC4uLn0="
```

The service account needs the **MANAGER** role on `GOOGLE_GROUP_EMAIL`, and the calendar has to be
shared with its address at "See all event details" — a share that never landed reads as a 404, not a
403.

The release also ships four database migrations, applied by the entrypoint before the server
listens. They are covered by the existing `config.MIGRATION_TIMEOUT` and the startup probe window;
with `persistence.enabled` and a `ReadWriteOnce` volume the chart already picks the `Recreate`
strategy, so no second replica runs them concurrently.

### 0.2.x to 0.3.0

`config.BETTER_AUTH_URL` is renamed to `config.APP_URL`, following the rename in the application.
The value is the same; only the key changes.

```yaml
# before
config:
  BETTER_AUTH_URL: https://backstage.example.com

# after
config:
  APP_URL: https://backstage.example.com
```

Nothing fails loudly when this is missed. The old key still renders into the ConfigMap, as an
environment variable the application ignores, and `APP_URL` falls back to the chart default. Login
then redirects to that default host, and the avatar URLs handed to Authentik point at it too.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for the deployment |
| autoscaling.enabled | bool | `false` | Controls whether autoscaling is enabled for the deployment. Scaling past one replica needs `config.AVATAR_STORAGE` set to "s3", or a ReadWriteMany volume. |
| autoscaling.maxReplicas | int | `10` | Sets the maximum number of application instances (replicas) that can be scaled up to during high demand |
| autoscaling.minReplicas | int | `1` | Defines the minimum number of application instances (replicas) to maintain, even during low demand |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the CPU utilization threshold at which autoscaling will be triggered to adjust the number of replicas |
| cacheSizeLimit | string | `"512Mi"` | Size limit for the Next.js cache emptyDir, where `next/image` writes what it optimizes |
| config | object | `{"APP_URL":"https://backstage.example.com","AUTHENTIK_CLIENT_ID":"","AUTHENTIK_GROUP_ADMIN":"","AUTHENTIK_GROUP_ALUMNI":"","AUTHENTIK_GROUP_API_CLIENTS":"backstage-api-clients","AUTHENTIK_GROUP_CANDIDATE":"","AUTHENTIK_GROUP_CANDIDATE_CANDIDATE":"","AUTHENTIK_GROUP_LEADERSHIP":"","AUTHENTIK_GROUP_LEADERSHIP_UUID":"","AUTHENTIK_GROUP_MEMBER":"","AUTHENTIK_ISSUER":"https://auth.example.com/application/o/backstage","AUTHENTIK_URL":"https://auth.example.com","AVATAR_STORAGE":"local","GOOGLE_ALUMNI_GROUP_EMAIL":"","GOOGLE_CALENDAR_ID":"","GOOGLE_GROUP_EMAIL":"","MIGRATION_TIMEOUT":"300","RUN_MIGRATIONS":"true","WEBSITE_URL":"https://bsstudio.hu"}` | Non-secret environment variables rendered into a ConfigMap. Keys are the literal names from <https://github.com/BSStudio/backstage/blob/main/.env.example>; empty values are dropped. `NEXT_PUBLIC_*` settings are absent because `next build` freezes them into the image. |
| config.APP_URL | string | `"https://backstage.example.com"` | Publicly accessible URL. The OIDC callback and the avatar URLs handed to Authentik are built from it, so it has to match the ingress host and the redirect URI registered in Authentik. |
| config.AUTHENTIK_CLIENT_ID | string | `""` | OIDC client ID, also the audience the machine-to-machine API checks tokens against |
| config.AUTHENTIK_GROUP_ADMIN | string | `""` | Authentik group name that grants the ADMIN role |
| config.AUTHENTIK_GROUP_ALUMNI | string | `""` | UUID of the Authentik group for alumni ("öregtag") |
| config.AUTHENTIK_GROUP_API_CLIENTS | string | `"backstage-api-clients"` | Authentik group name a machine-to-machine API client must be in |
| config.AUTHENTIK_GROUP_CANDIDATE | string | `""` | UUID of the Authentik group for candidates ("jelölt") |
| config.AUTHENTIK_GROUP_CANDIDATE_CANDIDATE | string | `""` | UUID of the Authentik group for candidate candidates ("jelölt-jelölt") |
| config.AUTHENTIK_GROUP_LEADERSHIP | string | `""` | Authentik group name that grants the LEADERSHIP role |
| config.AUTHENTIK_GROUP_LEADERSHIP_UUID | string | `""` | UUID of the common Leadership group in Authentik |
| config.AUTHENTIK_GROUP_MEMBER | string | `""` | UUID of the Authentik group for members ("stúdiós") |
| config.AUTHENTIK_ISSUER | string | `"https://auth.example.com/application/o/backstage"` | OIDC issuer, the Authentik application's provider URL. Blanking it takes down every auth route, not just login. |
| config.AUTHENTIK_URL | string | `"https://auth.example.com"` | Base URL of the Authentik instance, for its REST API |
| config.AVATAR_STORAGE | string | `"local"` | Avatar storage backend, "local" or "s3". "local" needs `persistence`. |
| config.GOOGLE_ALUMNI_GROUP_EMAIL | string | `""` | Second list joined when a member becomes an alumnus. Unset, the alumni jobs land as `SKIPPED`. |
| config.GOOGLE_CALENDAR_ID | string | `""` | Studio calendar shown on the dashboard, shared with the service account's address at "See all event details". Unset, the widget is dropped rather than failing. |
| config.GOOGLE_GROUP_EMAIL | string | `""` | Main mailing list the member addresses are synced to. Unset, every Google job lands as `SKIPPED` and the reconciliation page reports nothing configured. |
| config.MIGRATION_TIMEOUT | string | `"300"` | Seconds the entrypoint waits for migrations before failing the container |
| config.RUN_MIGRATIONS | string | `"true"` | Apply database migrations from the entrypoint before the server starts |
| config.WEBSITE_URL | string | `"https://bsstudio.hu"` | Base URL of the legacy Drupal website that member data is synced to |
| existingSecret | string | `""` | Read the sensitive environment variables from an existing Secret instead of `secrets`. Its keys must be the environment variable names. DATABASE_URL below stays chart-managed. |
| extraEnv | list | `[]` | Additional environment variables, appended to the container verbatim. Prefer `config` and `secrets`; entries here take precedence over both. |
| extraEnvFrom | list | `[]` | Additional envFrom sources appended to the container |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the containers |
| extraVolumes | list | `[]` | Additional volumes to mount to the deployment |
| fullnameOverride | string | `""` | String to fully override `"backstage.fullname"` |
| image.imagePullPolicy | string | `"IfNotPresent"` | The logic of image pulling |
| image.repository | string | `"ghcr.io/bsstudio/backstage"` | The Docker repository to pull the image from |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Secrets for pulling the image from a private registry |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Defines which ingress controller will implement the resource |
| ingress.enabled | bool | `false` | Enable an ingress resource |
| ingress.hosts | list | `[]` | List of ingress hosts. Must match `config.APP_URL`, where the OIDC callback lands. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to the deployment |
| lifecycle | object | `{}` | Container lifecycle hooks. A `preStop` sleep holds the pod open until its endpoint removal has propagated, and is charged against `terminationGracePeriodSeconds`. |
| livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"tcpSocket":{"port":"http"}}` | Liveness probe for the container. `tcpSocket`, not `/api/health`: that endpoint queries the database. |
| nameOverride | string | `""` | Provide a name in place of `backstage` |
| nodeSelector | object | `{}` | NodeSelector for the deployment |
| pdb.enabled | bool | `false` | Enable a PodDisruptionBudget. With a single replica `minAvailable: 1` blocks node drains. |
| pdb.maxUnavailable | string | `""` | Maximum unavailable pods (takes precedence over minAvailable when set) |
| pdb.minAvailable | string | `""` | Minimum available pods (used when maxUnavailable is unset; defaults to 1) |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the volume. ReadWriteMany is required to run more than one replica while `config.AVATAR_STORAGE` is "local". |
| persistence.annotations | object | `{}` | Annotations to add to the PVC, e.g. `helm.sh/resource-policy: keep` to retain data on uninstall |
| persistence.enabled | bool | `true` | Claim a volume for `/app/storage`, where the app keeps uploaded avatars. With `config.AVATAR_STORAGE` set to "local" and this off, uploads fail on the read-only filesystem. |
| persistence.size | string | `"2Gi"` | Defines the amount of storage allocated for persistence |
| podAnnotations | object | `{}` | Optional additional annotations to add to the pods |
| podLabels | object | `{}` | Optional additional labels to add to the pods |
| podSecurityContext | object | `{}` | Pod-level security context, merged over chart defaults (fsGroup 65532 for volume writes) |
| postgres.auth.database | string | `"backstage"` | Name for a custom database to create |
| postgres.auth.password | string | `""` | Password for the custom user. Required, and must be URL-safe: it is interpolated into `secrets.DATABASE_URL`. |
| postgres.auth.username | string | `"backstage"` | Name for a custom user to create |
| postgres.containerSecurityContext.runAsGroup | int | `65534` | Run container processes with nobody group |
| postgres.containerSecurityContext.runAsUser | int | `65534` | Run container processes as non-root user nobody |
| postgres.containerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use the container runtime default seccomp profile |
| postgres.enabled | bool | `true` | Enable the CloudPirates PostgreSQL chart. Refer to <https://github.com/CloudPirates-io/helm-charts/blob/main/charts/postgres> for possible values. |
| postgres.resources.limits.cpu | string | `"500m"` | The maximum amount of CPU the container can use |
| postgres.resources.limits.memory | string | `"512Mi"` | The maximum amount of memory the container can use |
| postgres.resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| postgres.resources.requests.memory | string | `"512Mi"` | Specifies the minimum amount of memory that will be allocated to the container |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/api/health","port":"http"},"initialDelaySeconds":5,"periodSeconds":10}` | Readiness probe for the container |
| replicaCount | int | `1` | The number of replicas to deploy (ignored when autoscaling is enabled). Each replica keeps its own in-memory rate-limit counters for the machine-to-machine API. |
| resources.limits.cpu | string | `"1000m"` | The maximum amount of CPU the container can use |
| resources.limits.memory | string | `"1Gi"` | The maximum amount of memory the container can use |
| resources.requests.cpu | string | `"250m"` | Specifies the minimum amount of CPU that will be allocated to the container |
| resources.requests.memory | string | `"1Gi"` | Specifies the minimum amount of memory that will be allocated to the container |
| secrets | object | `{"AUTHENTIK_API_TOKEN":"","AUTHENTIK_CLIENT_SECRET":"","BETTER_AUTH_SECRET":"","GOOGLE_SERVICE_ACCOUNT_KEY":"","WEBSITE_ADMIN_PASSWORD":"","WEBSITE_ADMIN_USERNAME":""}` | Sensitive environment variables rendered into a Secret. Keys are the literal names from <https://github.com/BSStudio/backstage/blob/main/.env.example>. DATABASE_URL defaults to the bundled sub-chart; set it to point at an external database. |
| secrets.AUTHENTIK_API_TOKEN | string | `""` | Authentik REST API token, used for the user and group syncs |
| secrets.AUTHENTIK_CLIENT_SECRET | string | `""` | OIDC client secret of the Authentik application |
| secrets.BETTER_AUTH_SECRET | string | `""` | Signing key for session cookies; the app will not start without it. `openssl rand -base64 32` |
| secrets.GOOGLE_SERVICE_ACCOUNT_KEY | string | `""` | Google service account JSON key, base64-encoded, used for both the group sync and the calendar read. The account needs the MANAGER role on `config.GOOGLE_GROUP_EMAIL`. |
| secrets.WEBSITE_ADMIN_PASSWORD | string | `""` | Password of that administrator account |
| secrets.WEBSITE_ADMIN_USERNAME | string | `""` | Administrator account on the legacy website, used for the website sync |
| securityContext | object | `{}` | Run containers as a specific securityContext, merged over chart defaults (runAsUser 65532, the UID the image chowns its files to; readOnlyRootFilesystem; capabilities drop ALL) |
| service.port | int | `3000` | Port number for web traffic (passed to the container as `PORT`) |
| service.type | string | `"ClusterIP"` | Kubernetes service type for web traffic |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `false` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| startupProbe | object | `{"failureThreshold":40,"httpGet":{"path":"/api/health","port":"http"},"initialDelaySeconds":10,"periodSeconds":10}` | Startup probe for the container. Its window must outlast `config.MIGRATION_TIMEOUT`: the entrypoint migrates before the server listens. |
| strategy | object | `{}` | Deployment update strategy. When empty, defaults to `Recreate` if persistence is enabled with a non-`ReadWriteMany` access mode (avoids a RWO volume deadlock on upgrade), otherwise Kubernetes' default RollingUpdate is used. |
| terminationGracePeriodSeconds | int | `60` | Grace period for shutdown. Next.js drains in-flight requests with no deadline of its own, and syncs to Authentik and the website run inside the request that triggered them. |
| tolerations | list | `[]` | Tolerations for the deployment |
