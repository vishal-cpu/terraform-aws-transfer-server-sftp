locals {
  is_vpc             = var.vpc_id != null
  restricted_users   = [for user in var.sftp_users : user if user.restricted_home]
  unrestricted_users = [for user in var.sftp_users : user if !user.restricted_home]
}

resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = var.identity_provider_type
  protocols              = var.protocols
  domain                 = var.domain
  endpoint_type          = local.is_vpc ? "VPC" : "PUBLIC"
  force_destroy          = var.force_destroy
  security_policy_name   = var.security_policy_name
  logging_role           = var.logging_role

  dynamic "endpoint_details" {
    for_each = local.is_vpc ? [1] : []
    content {
      subnet_ids             = var.subnet_ids
      security_group_ids     = var.vpc_security_group_ids
      vpc_id                 = var.vpc_id
      address_allocation_ids = var.eip_enabled ? aws_eip.sftp[*].id : var.address_allocation_ids
    }
  }

  tags = var.tags
}

resource "aws_transfer_tag" "route53_zone_id" {
  for_each     = { for k, v in var.tags : k => v if k == "aws:transfer:route53HostedZoneId" }
  resource_arn = aws_transfer_server.transfer_server.arn
  key          = each.key
  value        = each.value
}

resource "aws_transfer_tag" "custom_hostname" {
  for_each     = { for k, v in var.tags : k => v if k == "aws:transfer:customHostname" }
  resource_arn = aws_transfer_server.transfer_server.arn
  key          = each.key
  value        = each.value
}

resource "aws_transfer_user" "transfer_server_user_restricted" {
  count = length(local.restricted_users)

  user_name           = local.restricted_users[count.index].user_name
  role                = var.role
  server_id           = aws_transfer_server.transfer_server.id
  home_directory_type = "LOGICAL"

  dynamic "home_directory_mappings" {
    for_each = local.restricted_users[count.index].restricted_home ? [
      {
        entry  = "/"
        target = format("/%s/%s", join(",", local.restricted_users[count.index].s3_buckets), local.restricted_users[count.index].home_directory)
      }
    ] : []

    content {
      entry  = lookup(home_directory_mappings.value, "entry")
      target = lookup(home_directory_mappings.value, "target")
    }
  }
}

resource "aws_transfer_ssh_key" "transfer_server_ssh_key_restricted" {
  count     = length(local.restricted_users)
  server_id = aws_transfer_server.transfer_server.id
  user_name = local.restricted_users[count.index].user_name
  body      = local.restricted_users[count.index].ssh_public_key
  depends_on = [
    aws_transfer_user.transfer_server_user_restricted
  ]
}

resource "aws_transfer_user" "transfer_server_user" {
  count = length(local.unrestricted_users)

  user_name           = local.unrestricted_users[count.index].user_name
  role                = var.role
  server_id           = aws_transfer_server.transfer_server.id
  home_directory_type = "PATH"

  home_directory = format("/%s/%s", join(",", local.unrestricted_users[count.index].s3_buckets), local.unrestricted_users[count.index].home_directory)
}

resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  count     = length(local.unrestricted_users)
  server_id = aws_transfer_server.transfer_server.id
  user_name = local.unrestricted_users[count.index].user_name
  body      = local.unrestricted_users[count.index].ssh_public_key
  depends_on = [
    aws_transfer_user.transfer_server_user
  ]
}

resource "aws_eip" "sftp" {
  count = var.eip_enabled ? length(var.subnet_ids) : 0
  vpc   = local.is_vpc
}

resource "aws_route53_record" "main" {
  count   = length(var.domain_name) > 0 && length(var.zone_id) > 0 ? 1 : 0
  name    = var.domain_name
  zone_id = var.zone_id
  type    = "CNAME"
  ttl     = "300"
  records = [
    aws_transfer_server.transfer_server.endpoint
  ]
}



#############################################
#Custome Hostname Reference in Calling Module
#############################################

# zone_id      = "${Hosted zone ID}"
# domain_name  = "${module.labels.id}.${Hosted zone name}"
# tags = merge(module.labels.tags,
#   {
#     "aws:transfer:route53HostedZoneId" = "/hostedzone/"${Hosted zone ID}"",
#     "aws:transfer:customHostname"      = "${module.labels.id}.${Hosted zone name}"
#   }
# )