output "nat_gateway_id" {
  description = "NAT Gateway resource ID."
  value       = azapi_resource.nat_gateway.id
}

output "nat_gateway_name" {
  description = "NAT Gateway name."
  value       = azapi_resource.nat_gateway.name
}

output "public_ip_ids" {
  description = "Created Public IP IDs."
  value       = [for pip in azapi_resource.public_ip : pip.id]
}

output "public_ip_names" {
  description = "Created Public IP names."
  value       = [for pip in azapi_resource.public_ip : pip.name]
}
