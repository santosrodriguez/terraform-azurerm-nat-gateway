variable "solution_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the NAT Gateway and optional public IP resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}


variable "sku_name" {
  description = "NAT Gateway SKU. Defaults to StandardV2."
  type        = string
  default     = "StandardV2"

  validation {
    condition     = contains(["Standard", "StandardV2"], var.sku_name)
    error_message = "sku_name must be either Standard or StandardV2."
  }
}

variable "idle_timeout_in_minutes" {
  description = "Idle timeout for the NAT Gateway."
  type        = number
  default     = 4

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120
    error_message = "idle_timeout_in_minutes must be between 4 and 120."
  }
}

variable "zones" {
  description = "Availability zones. For StandardV2, use zone-redundant public IPs and avoid forcing zones unless you have a specific reason."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "create_public_ips" {
  description = "Whether the module should create Public IPs."
  type        = bool
  default     = true
}

variable "public_ip_count" {
  description = "Number of Public IPs to create."
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 0
    error_message = "public_ip_count must be 0 or greater."
  }
}

variable "public_ip_version" {
  description = "IP version for created Public IPs."
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.public_ip_version)
    error_message = "public_ip_version must be either IPv4 or IPv6."
  }
}

variable "public_ip_names" {
  description = "Optional explicit names for created Public IPs. If empty, names are generated."
  type        = list(string)
  default     = []
}

variable "public_ip_ids" {
  description = "Existing Public IP resource IDs to attach to the NAT Gateway."
  type        = list(string)
  default     = []
}

variable "public_ip_prefix_ids" {
  description = "Existing Public IP Prefix resource IDs to attach to the NAT Gateway."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnet IDs to associate with the NAT Gateway."
  type        = list(string)
  default     = []
}
