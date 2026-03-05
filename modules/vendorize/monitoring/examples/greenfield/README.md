# Greenfield Example — Full Infrastructure from Scratch

This example provisions a complete AWS environment including a VPC, an EKS cluster, and the WeAura Monitoring Stack from zero.

## Features

- ✅ **Complete VPC**: Public and private subnets across multiple AZs.
- ✅ **EKS Cluster**: Choice between Managed Node Groups or EKS Auto Mode.
- ✅ **Monitoring Stack**: Deploys Grafana, Loki, Mimir, Tempo, and Prometheus.
- ✅ **Harbor OCI Registry**: Configured to pull charts securely.

## Prerequisites

1.  **AWS Account**: An active AWS account with permissions for VPC, EKS, IAM, and S3.
2.  **Harbor Credentials**: Robot account for chart distribution.
3.  **Terraform CLI**: Installed and configured.

## Usage

1.  **Prepare Variables**:
    Copy the example variable file and update it with your project name, AWS region, and Harbor credentials.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your values
    ```

2.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

3.  **Plan and Apply**:
    ```bash
    terraform plan
    terraform apply
    ```

## EKS Auto Mode

This example includes an option to enable **EKS Auto Mode**. Set `enable_auto_mode = true` in your variables to leverage simplified compute management and EKS Pod Identity.

## Cost Warning

Provisioning this example will incur costs for:
- EKS cluster management
- NAT Gateways
- EC2 worker nodes (if using Managed Node Groups)
- S3 storage

## Documentation

- [variables.tf](./variables.tf)
- [terraform.tfvars.example](./terraform.tfvars.example)
