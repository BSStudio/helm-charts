<p align="center">
  <img src="https://bsstudio.hu/system/files/site_content/logo/bss_logo_169.png" width="50%" alt="Budavári Schönherz Stúdió logo">
</p>

---

# Helm Charts

This repository contains Helm charts used to deploy and manage applications and infrastructure for Budavári Schönherz Stúdió.

## Get Started

```bash
helm repo add bsstudio https://charts.bsstudio.hu
helm search repo bsstudio
helm install example bsstudio/<chart>
```

## Contributing

If you want to add a new application or change on of the existing ones please follow the steps here.

### Pre-commit

Pre-commit will make sure that your changes follow the guidelines of this repo. To enable the hooks to the following:

```bash
python -m venv venv

# Windows
venv\Scripts\Activate.ps1

# Linux or macOS
source venv/bin/activate

pip install -r requirements.txt

pre-commit install
```

> [!NOTE]
> If your `pip install` fails, check [checkov's requirements](https://github.com/bridgecrewio/checkov#requirements). Your Python version might not be supported.

### Checkov

Before pushing your changes to the repo run the checkov scan locally.

```bash
checkov -d . --skip-path venv
```

Checkov should be installed from the previous `pre-commit` step.
