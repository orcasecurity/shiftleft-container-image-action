# Orca Shift Left Security Action

[GitHub Action](https://github.com/features/actions)
for [Orca Shift Left Security](https://orca.security/solutions/shift-left-security/)

#### More info can be found in the official Orca Shift Left Security<a href="https://docs.orcasecurity.io/v1/docs/shift-left-security"> documentation</a>



## Table of Contents

- [Usage](#usage)
    - [Workflow](#workflow)
    - [Inputs](#inputs)
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
        uses: orcasecurity/shiftleft-container-image-action@v1
        with:
          api_token: ${{ secrets.ORCA_SECURITY_API_TOKEN }}
          project_key: ${{ env.PROJECT_KEY }}
          image: <image to scan>
          output:
            "results/"
```

### Inputs

| Variable                | Example Value &nbsp; | Description &nbsp;                                                                | Type    | Required | Default |
|-------------------------|----------------------|-----------------------------------------------------------------------------------|---------|----------|---------|
| api_token               |                      | Orca API Token used for Authentication                                            | String  | Yes      | N/A     |
| project_key             | my-project-key       | Project Key name                                                                  | String  | Yes      | N/A     |
| image                   | redis:latest         | Image name and tag to scan                                                        | String  | Yes      | N/A     |
| format                  | json                 | Format for displaying the results                                                 | String  | No       | cli     |
| output                  | results/             | Output directory                                                                  | String  | No       | N/A     |
| no_color                | false                | Disable color output                                                              | Boolean | No       | false   |
| exit_code               | 10                   | Exit code for failed execution due to policy violations                           | Integer | No       | 3       |
| silent                  | false                | Disable logs and warnings output                                                  | Boolean | No       | false   |
| console_output          | json                 | Prints results to console in the provided format (only when --output is provided) | String  | No       | cli     |
| config                  | config.json          | path to configuration file (json, yaml or toml)                                   | String  | No       | N/A     |
| disable_secret          | true                 | Disables the secret detection scanning                                            | Boolean | No       | false   |
| exceptions-filepath     | n/a                  | exceptions YAML filepath. (File should be mounted)                                | String  | No       | false   |
| hide_vulnerabilities    | n/a                  | do not show detailed view of the vulnerabilities findings                         | Boolean | No       | false   |
| num_cpu                 | 10                   | Number of logical CPUs to be used for secret scanning (default 10)                | Integer | No       | 10      |
| show_failed_issues_only | n/a                  | show only failed issues                                                           | Boolean | No       | false   |
| tar-archive             | n/a                  | scan a tar archived image. Input should be the path of the image .tar file        | Boolean | No       | false   |
| oci                     | n/a                  | scan an OCI image                                                                 | Boolean | No       | false   |



## Upload SARIF report
If you have [GitHub code scanning](https://docs.github.com/en/github/finding-security-vulnerabilities-and-errors-in-your-code/about-code-scanning) available you can use Orca Shift Left Security as a scanning tool
> **NOTE:**  Code scanning is available for all public repositories. Code scanning is also available in private repositories owned by organizations that use GitHub Enterprise Cloud and have a license for GitHub Advanced Security.

Configuration:

```yaml
name: Image Build, Scan and Upload Sarif

on: [pull_request]

jobs:
    build-cli:
      name: build-cli
      runs-on: ubuntu-latest
      env: 
        IMAGE_NAME: <image name>
        PROJECT_KEY: <project key> # Set the desired project to run the cli scanning with
      
      steps:
      # checks-out your repository under $GitHub_WORKSPACE, so your workflow can access it.
      - name: Checkout
        uses: actions/checkout@v2
      
      # Build your docker image, that is going to be scanned in the next step
      - name: Docker Image Build
        run: docker build -t $IMAGE_NAME .
  

      - name: Run Orca Container Image Scan
        uses: orcasecurity/shiftleft-container-image-action@v1
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
          sarif_file: results/image.sarif
```

The results list can be found on the security tab of your GitHub project and should look like the following image

![](/assets/container_scanning_list.png)

An entry should describe the error and in which line it occurred 

![](/assets/scanned_entry.png)
