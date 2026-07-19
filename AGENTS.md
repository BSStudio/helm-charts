# Repository guidance

Read [CONVENTIONS.md](CONVENTIONS.md) before creating or changing a chart. It is the authority on
chart structure, values naming, and the rules that are easy to get wrong. `charts/outline` and
`charts/request-manager` are the reference implementations.

Verify before asserting. Whether a health endpoint touches the database, what an app's shutdown
timeout is, which settings it reads with no default — read the upstream source rather than assuming.
These decide chart behaviour, and a wrong guess sends the work in the wrong direction.

`helm template` and `helm lint` do not prove the app starts. Say so when reporting results, and
treat the `ct install` run on the PR as the first real test.
