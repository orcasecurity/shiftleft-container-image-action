# Orca Shift Left Security Action

[GitHub Action](https://github.com/features/actions)
for [Orca Shift Left Security](https://orca.security/solutions/shift-left-security/)

#### More info can be found in the official Orca Shift Left Security<a href="https://docs.orcasecurity.io/v1/docs/shift-left-security"> documentation</a>



## Table of Contents

- [Usage](#usage)
    - [Workflow](#workflow)
    - [Inputs](#inputs)
- [Annotations](#annotations)
- [Upload SARIF report](#upload-sarif-report)


## Usage

### Workflow

```yaml
name: Sample Orca Container Image Scan Workflow
on:
  # Trigger the workflow on push request,
  # but only for the main branch
  push:
    branches:
      - main
jobs:
  orca-container_scan:
    name: Orca Container Image Scan
    runs-on: ubuntu-latest
    env:
      PROJECT_KEY: <project key> # Set the desired project to run the cli scanning with
    steps:
      # Checkout your repository under $GITHUB_WORKSPACE, so your job can access it
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Run Orca Container Image Scan
        uses: orcasecurity/shiftleft-container-action@v1
        with:
          api_token: ${{ secrets.ORCA_SECURITY_API_TOKEN }}
          project_key: ${{ env.PROJECT_KEY }}
          image:
            # scanning image
            "redis:latest"
```

### Inputs

| Variable         | Example Value &nbsp;         | Description &nbsp;                                                                | Type    | Required | Default                       |
|------------------|------------------------------|-----------------------------------------------------------------------------------|---------|----------|-------------------------------|
| api_token        |                              | Orca API Token used for Authentication                                            | String  | Yes      | N/A                           |
| project_key      | my-project-key               | Project Key name                                                                  | String  | Yes      | N/A                           |
| image            | redis:latest                 | Image name and tag to scan                                                        | String  | Yes      | N/A                           |
| format           | json                         | Format for displaying the results                                                 | String  | No       | cli                           |
| output           | ./results                    | Output file name                                                                  | String  | No       | N/A                           |
| no_color         | false                        | Disable color output                                                              | Boolean | No       | false                         |
| exit_code        | 10                           | Exit code for failed execution due to policy violations                           | Integer | No       | 3                             |
| silent           | false                        | Disable logs and warnings output                                                  | Boolean | No       | false                         |
| console-output   | json                         | Prints results to console in the provided format (only when --output is provided) | String  | No       | cli                           |
| config           | config.json                  | path to configuration file (json, yaml or toml)                                   | String  | No       | N/A                           |



## Upload SARIF report
If you have [GitHub code scanning](https://docs.github.com/en/github/finding-security-vulnerabilities-and-errors-in-your-code/about-code-scanning) available you can use Orca Shift Left Security as a scanning tool
> **NOTE:**  Code scanning is available for all public repositories. Code scanning is also available in private repositories owned by organizations that use GitHub Enterprise Cloud and have a license for GitHub Advanced Security.

Configuration:

```yaml
name: Scan and upload SARIF

push:
  branches:
    - main

jobs:
  orca-container_scan:
    name: Orca Container Image Scan
    runs-on: ubuntu-latest
    env:
      PROJECT_KEY: <project key> # Set the desired project to run the cli scanning with
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Run Orca Container Image Scan
        uses: orcasecurity/shiftleft-container-action@v1
        with:
          api_token: ${{ secrets.ORCA_SECURITY_API_TOKEN }}
          project_key: ${{ env.PROJECT_KEY }}
          image: <image to scan>
          format: "sarif"
          output:
            "results/"
      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: results/container.sarif
```

The results list can be found on the security tab of your GitHub project and should look like the following image

![](/assets/code_scanning_screen.png)

An entry should describe the error and in which line it occurred 

![](/assets/alerts_screen.png)
