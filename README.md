# qj_infra

Infrastructure as Code (IaC) project utilizing Terraform to provision and manage AWS resources for the Quantify Jiu-Jitsu platform.

## Features

- **AWS Resource Management**: Automates the creation and management of various AWS services including ACM, API Gateway, Bastion Hosts, CloudWatch, IAM roles and policies, Lambda functions, Networking components, RDS instances, and S3 buckets.
- **Modular Terraform Configuration**: Organized Terraform scripts for modular and maintainable infrastructure deployment.

## Prerequisites

- **Terraform**: Ensure Terraform is installed.
- **AWS CLI**: AWS Command Line Interface should be installed and configured with appropriate credentials.

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/kuanting-wu/qj_infra.git
   ```

2. **Navigate to the Project Directory**:

   ```bash
   cd qj_infra
   ```

3. **Initialize Terraform**:

   ```bash
   terraform init
   ```

## Usage

- **Plan the Infrastructure**:

  ```bash
  terraform plan
  ```

- **Apply the Infrastructure**:

  ```bash
  terraform apply
  ```

- **Destroy the Infrastructure**:

  ```bash
  terraform destroy
  ```

## Project Structure

```
qj_infra/
├── acm.tf              # AWS Certificate Manager resources
├── apigateway.tf       # API Gateway configurations
├── bastion.tf          # Bastion host setup
├── cloudwatch.tf       # CloudWatch monitoring setup
├── iam.tf              # IAM roles and policies
├── lambda.tf           # Lambda function configurations
├── main.tf             # Main Terraform configuration
├── networking.tf       # VPC, subnets, and networking resources
├── output.tf           # Output variables
├── rds.tf              # RDS instance configurations
├── s3.tf               # S3 bucket configurations
└── variables.tf        # Input variables
```
