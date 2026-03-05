# Complete Example — Monitoring on Existing EKS

This example demonstrates how to deploy the WeAura Monitoring Stack onto an existing EKS cluster with all components and enterprise features enabled.

## Features

- ✅ **Full Component Stack**: Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope.
- ✅ **Enterprise Features**: PodDisruptionBudgets, alerting rules, and ServiceMonitors.
- ✅ **Infrastructure Integration**: Configures S3 bucket prefixing and CloudWatch alarms for storage.
- ✅ **Harbor OCI Distribution**: Pulls charts from the WeAura Harbor registry.

## Prerequisites

1.  **Existing EKS Cluster**: Ensure your EKS cluster is running and your local environment is configured for access.
2.  **Harbor Credentials**: Obtain a robot account username and password from the WeAura team.
3.  **AWS Credentials**: Sufficient permissions to create S3 buckets and IAM roles.

## Usage

1.  **Prepare tfvars**:
    Copy the example variable file and update it with your cluster name, region, and Harbor credentials.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your values
    ```

2.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

3.  **Plan Deployment**:
    ```bash
    terraform plan
    ```

4.  **Apply Changes**:
    ```bash
    terraform apply
    ```

5.  **Destroy Resources**:
    ```bash
    terraform destroy
    ```

## Variable Links

- [variables.tf](./variables.tf)
- [terraform.tfvars.example](./terraform.tfvars.example)

## Documentation

For detailed information on the underlying monitoring module, see the [parent module README](../../README.md).
