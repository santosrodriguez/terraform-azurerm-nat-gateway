# Azure NAT Gateway Terraform Module

This Terraform module deploys an Azure NAT Gateway using the `azapi` provider. It can optionally create one or more Public IP Addresses, attach existing Public IPs or Public IP Prefixes, and associate the NAT Gateway to one or more subnets.

## What This Module Creates

- Azure NAT Gateway
- Optional Azure Public IP Addresses
- Optional NAT Gateway subnet associations
- Support for existing Public IP IDs
- Support for existing Public IP Prefix IDs

## Providers

| Provider | Source |
|---|---|
| `azurerm` | `hashicorp/azurerm` |
| `azapi` | `Azure/azapi` |
| `random` | `hashicorp/random` |

> **Note:** This module uses `azurerm_client_config` to automatically derive the current subscription ID and build the target resource group ID from the supplied resource group name.

## Naming

The NAT Gateway name is generated using the following pattern:

```text
ng-<solution_name>-<environment>-<location>-<random_suffix>
```

Created Public IP names use this pattern:

```text
ng-<solution_name>-<environment>-<location>-<random_suffix>-pip-01
```

You can override generated Public IP names by passing `public_ip_names`.

## Usage

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  solution_name       = "app1"
  environment         = "dev"
  resource_group_name = "rg-app1-network-dev-01"
  location            = "eastus"

  sku_name                = "StandardV2"
  idle_timeout_in_minutes = 4

  create_public_ips = true
  public_ip_count   = 1
  public_ip_version = "IPv4"

  subnet_ids = [
    azurerm_subnet.app.id
  ]

  tags = {
    environment = "dev"
    workload    = "app1"
  }
}
```

## Usage With Existing Public IPs

Use this pattern when Public IPs are created outside the module and should be attached to the NAT Gateway.

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  solution_name       = "app1"
  environment         = "prd"
  resource_group_name = "rg-app1-network-prd-01"
  location            = "eastus"

  create_public_ips = false

  public_ip_ids = [
    azurerm_public_ip.nat.id
  ]

  subnet_ids = [
    azurerm_subnet.app.id
  ]

  tags = {
    environment = "prd"
    workload    = "app1"
  }
}
```

## Usage With Public IP Prefixes

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  solution_name       = "app1"
  environment         = "prd"
  resource_group_name = "rg-app1-network-prd-01"
  location            = "eastus"

  create_public_ips = false

  public_ip_prefix_ids = [
    azurerm_public_ip_prefix.nat.id
  ]

  subnet_ids = [
    azurerm_subnet.app.id
  ]

  tags = {
    environment = "prd"
    workload    = "app1"
  }
}
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---:|:---:|---:|---|
| `solution_name` | `string` | Yes | n/a | Short workload or application name used in resource naming. |
| `environment` | `string` | Yes | n/a | Environment name, such as `dev`, `int`, `crt`, or `prd`. |
| `resource_group_name` | `string` | Yes | n/a | Resource group where the NAT Gateway and optional Public IPs are deployed. |
| `location` | `string` | Yes | n/a | Azure region. |
| `sku_name` | `string` | No | `StandardV2` | NAT Gateway SKU. Allowed values: `Standard`, `StandardV2`. |
| `idle_timeout_in_minutes` | `number` | No | `4` | NAT Gateway idle timeout. Must be between `4` and `120`. |
| `zones` | `list(string)` | No | `[]` | Availability zones for created resources. |
| `tags` | `map(string)` | No | `{}` | Tags applied to resources. |
| `create_public_ips` | `bool` | No | `true` | Whether the module creates Public IPs. |
| `public_ip_count` | `number` | No | `1` | Number of Public IPs to create. |
| `public_ip_version` | `string` | No | `IPv4` | IP version for created Public IPs. Allowed values: `IPv4`, `IPv6`. |
| `public_ip_names` | `list(string)` | No | `[]` | Optional explicit names for created Public IPs. |
| `public_ip_ids` | `list(string)` | No | `[]` | Existing Public IP resource IDs to attach to the NAT Gateway. |
| `public_ip_prefix_ids` | `list(string)` | No | `[]` | Existing Public IP Prefix resource IDs to attach to the NAT Gateway. |
| `subnet_ids` | `list(string)` | No | `[]` | Subnet IDs to associate with the NAT Gateway. |

## Outputs

| Name | Description |
|---|---|
| `nat_gateway_id` | NAT Gateway resource ID. |
| `nat_gateway_name` | NAT Gateway name. |
| `public_ip_ids` | Created Public IP IDs. |
| `public_ip_names` | Created Public IP names. |

## Design Notes

- The module does **not** create the resource group. The resource group must already exist in the target subscription.
- The resource group ID is generated internally from the active subscription ID and `resource_group_name`.
- Subnet association is handled through `azapi_update_resource` against each subnet ID passed into `subnet_ids`.
- If `create_public_ips = false`, pass at least one value in `public_ip_ids` or `public_ip_prefix_ids`.
- For production workloads, prefer explicit subnet IDs from Terraform-managed subnets to avoid manual drift.
- Avoid manual changes to the NAT Gateway or subnet associations outside Terraform.

## Best Practices

- Use remote state stored in Azure Storage.
- Keep NAT Gateway ownership in the same state as the subnets it manages, or clearly separate ownership boundaries.
- Do not share the same subnet association across multiple Terraform states.
- Use `StandardV2` only where it is supported and intentionally selected.
- Tag all resources consistently for cost management, ownership, and environment tracking.

## Requirements

- Terraform installed locally or available through CI/CD.
- Authenticated Azure provider context.
- Existing resource group in the target subscription.
- Existing subnet IDs when associating NAT Gateway to subnets.
