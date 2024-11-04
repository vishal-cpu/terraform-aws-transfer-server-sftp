############################
# AWS Transfer Family Server
############################
module "sftp" {
  source = "../"
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

    # not_restricted

    {
      user_name       = "user_name"
      home_directory  = "home_directory"
      ssh_public_key  = "ssh_pub_key"
      s3_buckets      = ["s3_bucket"]
      restricted_home = false
    },
  ]

  identity_provider_type = "SERVICE_MANAGED" //other possible values:- API_GATEWAY, AWS_DIRECTORY_SERVICE and AWS_LAMBDA 
  protocols              = ["SFTP"]          //other possible values:- AS2, FTPS and FTP
  logging_role           = "logging_role"
  role                   = "role"
  zone_id                = "HostedZoneID"
  domain_name            = "${module.labels.id}.${HostedZoneName}"
  tags = merge("tags",
    {
      "aws:transfer:route53HostedZoneId" = "/hostedzone/${HostedZoneID}",
      "aws:transfer:customHostname"      = "${module.labels.id}.${HostedZoneName}"
    }
  )
}