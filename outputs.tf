output "transfer_server_id" {
  description = "ID of the created Transfer Server"
  value       = join("", aws_transfer_server.transfer_server.*.id)
}
output "transfer_server_endpoint" {
  description = "The endpoint of the Transfer Server"
  value       = join("", aws_transfer_server.transfer_server.*.endpoint)
}
output "transfer_server_hostname" {
  description = "The Zone_Id of the Transfer Server"
  value       = aws_transfer_tag.custom_hostname["aws:transfer:customHostname"].value
}
output "transfer_server_zone_id" {
  description = "The Custom Hostname of the Transfer Server"
  value       = aws_transfer_tag.route53_zone_id["aws:transfer:route53HostedZoneId"].value
}