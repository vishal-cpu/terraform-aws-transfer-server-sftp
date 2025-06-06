# Terraform AWS Transfer Family (SFTP) Server

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform Version](https://img.shields.io/badge/terraform-≥1.3.0-blue)](https://www.terraform.io/)


This Terraform module creates an AWS Transfer Server for SFTP access, along with user management, VPC and public endpoint configurations, and optional Route53 DNS records for custom domains. It also supports flexible user configuration with options for restricted and unrestricted home directories.

## Features

- **AWS Transfer Server** for SFTP access with customizable configurations
- **User Management**: Supports restricted (logical) and unrestricted (path) user home directories
- **VPC and Public Endpoint Support**: Select endpoint type based on `vpc_id` input
- **Elastic IP and DNS Configuration**: Optionally attach Elastic IPs and configure DNS records in Route 53 for custom domains

## Usage

```hcl
module "sftp_server" {
  source = "../"

  # Required variables
  identity_provider_type  = "SERVICE_MANAGED" # or use "API_GATEWAY"
  protocols               = ["SFTP"]
  domain                  = "s3"
  force_destroy           = true
  security_policy_name    = "TransferSecurityPolicy-2020-06"
  logging_role            = "arn:aws:iam::123456789012:role/TransferLoggingRole"
  vpc_id                  = "vpc-12345678"
  subnet_ids              = ["subnet-1234abcd"]
  vpc_security_group_ids  = ["sg-12345678"]
  eip_enabled             = true
  tags                    = {
    Name = "SFTPServer"
  }

  # User configuration
  sftp_users = [
    {
      user_name       = "user_name"
      home_directory  = "home_directory"
      ssh_public_key  = "ssh_pub_key"
      s3_buckets      = ["s3_bucket"]
      restricted_home = true
      home_directory_mappings = [
        {
          entry  = "/"
          target = "/home_directory"
        }
      ]
    },

    # non_restricted

    {
      user_name       = "user_name"
      home_directory  = "home_directory"
      ssh_public_key  = "ssh_pub_key"
      s3_buckets      = ["s3_bucket"]
      restricted_home = false
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | ≥ 1.3.0 |
| AWS Provider | ≥ 4.0 |

## Inputs

| Name                     | Type    | Description                                                                                 | Required |
|--------------------------|---------|---------------------------------------------------------------------------------------------|----------|
| `identity_provider_type` | string  | The identity provider type (`SERVICE_MANAGED` or `API_GATEWAY`).                            | yes      |
| `protocols`              | list    | List of supported protocols for the server (e.g., `["SFTP"]`).                              | yes      |
| `domain`                 | string  | The domain for the Transfer Server (e.g., `example.com`).                                   | yes      |
| `force_destroy`          | bool    | Whether to force destroy the Transfer Server on deletion.                                   | yes      |
| `security_policy_name`   | string  | Name of the security policy for the Transfer Server.                                        | yes      |
| `logging_role`           | string  | ARN of the IAM role used for logging.                                                       | yes      |
| `vpc_id`                 | string  | VPC ID for VPC endpoint configuration. If `null`, a public endpoint will be used.           | no       |
| `subnet_ids`             | list    | List of subnet IDs for VPC configuration.                                                   | no       |
| `vpc_security_group_ids` | list    | Security group IDs for the VPC endpoint.                                                    | no       |
| `eip_enabled`            | bool    | Whether to attach Elastic IPs to the endpoint.                                              | no       |
| `tags`                   | map     | Key-value tags to associate with the Transfer Server and its resources.                     | no       |
| `sftp_users`             | list    | List of SFTP users with attributes (`user_name`, `restricted_home`, `s3_buckets`, etc.).    | yes      |
| `zone_id`                | string  | Route 53 Zone ID for DNS configuration (required if `domain_name` is set).                  | no       |
| `domain_name`            | string  | Domain name for the CNAME record in Route 53.                                               | no       |

## Outputs

| Name                          | Description                                      |
|-------------------------------|--------------------------------------------------|
| `transfer_server_id`          | ID of the AWS Transfer Server                    |
| `transfer_server_arn`         | ARN of the AWS Transfer Server                   |
| `sftp_endpoint`               | Endpoint URL for accessing the Transfer Server   |

## Example Scenarios

### Basic SFTP Server with Public Endpoint
Deploy an AWS Transfer Server for SFTP with public access and a basic configuration for managed users.

### VPC Endpoint with Elastic IPs
Configure the Transfer Server in a VPC, attach Elastic IPs, and apply security groups for controlled access.

### Restricted and Unrestricted Users
Define users with restricted access to specific S3 paths and unrestricted users with broader access to directories.

## Authors
Module is maintained by [Vishal Saini](https://github.com/vishal-cpu).