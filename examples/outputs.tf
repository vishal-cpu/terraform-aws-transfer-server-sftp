output "transfer_server_id" {
  description = "ID of the created Transfer Server"
  value       = module.sftp.transfer_server_id
}
output "transfer_server_endpoint" {
  description = "Endpoint of the created Transfer Server"
  value       = module.sftp.transfer_server_endpoint
}