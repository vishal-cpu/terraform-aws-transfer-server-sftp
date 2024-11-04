variable "domain" {
  type        = string
  description = "Where your files are stored. S3 or EFS"
  default     = "S3"
}

variable "sftp_users" {
  description = "List of SFTP user_name, home_directory, ssh_public_key, s3_buckets, restricted_home and home_directory_mappings. The keys `user_name`, `home_directory`, ssh_public_key` and s3_buckets are required. The keys `restricted_home` and home_directory_mappings are optional."
  type = list(object({
    user_name       = string
    home_directory  = string
    ssh_public_key  = string
    s3_buckets      = list(string)
    restricted_home = optional(bool)
    home_directory_mappings = optional(list(object({
      entry  = string
      target = string
    })))
  }))
}

variable "force_destroy" {
  type        = bool
  description = "Forces the AWS Transfer Server to be destroyed"
  default     = false
}

variable "identity_provider_type" {
  type        = string
  description = "The mode of authentication enabled for this service"
  default     = ""
}

variable "protocols" {
  type        = list(string)
  default     = [""]
  description = "File transfer protocol over which your client can connect to your server's endpoint"
}

# Variables used when deploying to VPC
variable "vpc_id" {
  type        = string
  description = "VPC ID that the AWS Transfer Server will be deployed to"
  default     = null
}

variable "address_allocation_ids" {
  type        = list(string)
  description = "A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "vpc_endpoint_id" {
  type        = string
  description = "The ID of the VPC endpoint. This property can only be used when endpoint_type is set to VPC_ENDPOINT"
  default     = null
}

variable "security_policy_name" {
  type        = string
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11."
  default     = "TransferSecurityPolicy-2018-11"
}

variable "domain_name" {
  type        = string
  description = "Domain to use when connecting to the SFTP endpoint"
  default     = ""
}

variable "zone_id" {
  type        = string
  description = "Route53 Zone ID to add the CNAME"
  default     = ""
}

variable "eip_enabled" {
  type        = bool
  description = "Whether to provision and attach an Elastic IP to be used as the SFTP endpoint. An EIP will be provisioned per subnet."
  default     = false
}

variable "logging_role" {
  description = "The ARN of the logging IAM role"
  type        = string
}

variable "role" {
  description = "The ARN of the logging IAM role"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}