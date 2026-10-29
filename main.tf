data "azurerm_client_config" "current" {}




locals {
  name = "ng-${var.solution_name}-${var.environment}-${var.location}"

  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  generated_public_ip_names = [
    for i in range(var.public_ip_count) : format("%s-pip-%02d", local.name, i + 1)
  ]

  effective_public_ip_names = length(var.public_ip_names) > 0 ? var.public_ip_names : local.generated_public_ip_names

  create_pips = var.create_public_ips ? {
    for idx, pip_name in local.effective_public_ip_names : pip_name => {
      name = pip_name
    }
  } : {}

  nat_public_ip_ids = concat(
    [for pip in azapi_resource.public_ip : pip.id],
    var.public_ip_ids
  )
}

resource "azapi_resource" "public_ip" {
  for_each = local.create_pips

  type      = "Microsoft.Network/publicIPAddresses@2024-10-01"
  name      = each.value.name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    sku = {
      name = var.sku_name
      tier = "Regional"
    }
    zones = length(var.zones) > 0 ? var.zones : null
    properties = {
      publicIPAddressVersion   = var.public_ip_version
      publicIPAllocationMethod = "Static"
    }
  }

  response_export_values = [
    "id",
    "name",
    "properties.ipAddress"
  ]
}

resource "azapi_resource" "nat_gateway" {
  type      = "Microsoft.Network/natGateways@2024-07-01"
  name = local.name

  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    sku = {
      name = var.sku_name
    }
    zones = length(var.zones) > 0 ? var.zones : null
    properties = {
      idleTimeoutInMinutes = var.idle_timeout_in_minutes
      publicIpAddresses = [
        for id in local.nat_public_ip_ids : {
          id = id
        }
      ]
      publicIpPrefixes = [
        for id in var.public_ip_prefix_ids : {
          id = id
        }
      ]
    }
  }

  response_export_values = [
    "id",
    "name"
  ]
}

resource "azapi_update_resource" "subnet_nat_association" {
  for_each = toset(var.subnet_ids)

  type        = "Microsoft.Network/virtualNetworks/subnets@2024-07-01"
  resource_id = each.value

  body = {
    properties = {
      natGateway = {
        id = azapi_resource.nat_gateway.id
      }
    }
  }

  depends_on = [azapi_resource.nat_gateway]
}
