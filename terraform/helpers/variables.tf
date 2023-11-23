variable "azure_bastion_nsg_list" {
  default = {
    "AllowHttpsInbound"                       = { priority = "120", direction = "Inbound", source_port = "*", destination_port = "443", access = "Allow", protocol = "Tcp", source_address_prefix = "Internet", destination_address_prefix = "*" },
    "AllowGatewayManagerInbound"              = { priority = "130", direction = "Inbound", source_port = "*", destination_port = "443", access = "Allow", protocol = "Tcp", source_address_prefix = "GatewayManager", destination_address_prefix = "*" },
    "AllowAzureLoadBalancerInbound"           = { priority = "140", direction = "Inbound", source_port = "*", destination_port = "443", access = "Allow", protocol = "Tcp", source_address_prefix = "AzureLoadBalancer", destination_address_prefix = "*" },
    "AllowBastionHostCommunication1"          = { priority = "150", direction = "Inbound", source_port = "*", destination_port = "5701", access = "Allow", protocol = "Tcp", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
    "AllowBastionHostCommunication2"          = { priority = "155", direction = "Inbound", source_port = "*", destination_port = "80", access = "Allow", protocol = "Tcp", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
    "AllowSSHRDPOutbound1"                    = { priority = "160", direction = "Outbound", source_port = "*", destination_port = "22", access = "Allow", protocol = "Tcp", source_address_prefix = "*", destination_address_prefix = "VirtualNetwork" },
    "AllowSSHRDPOutbound2"                    = { priority = "165", direction = "Outbound", source_port = "*", destination_port = "3389", access = "Allow", protocol = "Tcp", source_address_prefix = "*", destination_address_prefix = "VirtualNetwork" },
    "AllowAzureCloudOutbound2"                = { priority = "170", direction = "Outbound", source_port = "*", destination_port = "443", access = "Allow", protocol = "Tcp", source_address_prefix = "*", destination_address_prefix = "AzureCloud" },
    "AllowAzureBastionCommunicationOutbound1" = { priority = "180", direction = "Outbound", source_port = "*", destination_port = "5701", access = "Allow", protocol = "Tcp", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
    "AllowAzureBastionCommunicationOutbound2" = { priority = "185", direction = "Outbound", source_port = "*", destination_port = "8080", access = "Allow", protocol = "Tcp", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
    "AllowGetSessionInformation"              = { priority = "190", direction = "Outbound", source_port = "*", destination_port = "80", access = "Allow", protocol = "Tcp", source_address_prefix = "*", destination_address_prefix = "*" },
  }
  description = "The Standard list of NSG rules needed to make a bastion work"
}

variable "bastion_host_ipconfig_name" {
  type        = string
  description = "The IP Configuration name for the Azure Bastion"
  default     = null
}

variable "bastion_host_name" {
  type        = string
  description = "The name for the Bastion host in the portal"
}

variable "bastion_nsg_location" {
  type        = string
  description = "The location of the bastion nsg"
  default     = null
}

variable "bastion_nsg_name" {
  type        = string
  description = "The name for the NSG to be created with the AzureBastionSubnet"
  default     = null
}

variable "bastion_nsg_rg_name" {
  type        = string
  description = "The resource group name which the NSG should be placed in"
  default     = null
}

variable "bastion_pip_allocation_method" {
  type        = string
  default     = "Static"
  description = "The allocation method for the Public IP, default is Static"
}

variable "bastion_pip_location" {
  type        = string
  description = "The location for the Bastion Public IP, default is UK South"
  default     = null
}

variable "bastion_pip_name" {
  type        = string
  description = "The name for the Bastion Public IP"
  default     = null
}

variable "bastion_pip_rg_name" {
  type        = string
  description = "The resource group name for Bastion Public IP"
  default     = null
}

variable "bastion_pip_sku" {
  type        = string
  default     = "Standard"
  description = "The SKU for the Bastion Public IP, default is Standard"
}

variable "bastion_sku" {
  type        = string
  description = "The SKU of the bastion, default is Basic"
  default     = "Basic"
}

variable "bastion_subnet_name" {
  default     = "AzureBastionSubnet"
  type        = string
  description = "The name of the Azure Bastion Subnet - note, this is a static value and should not be changed"
}

variable "bastion_subnet_range" {
  type        = string
  description = "The IP Range for the Bastion Subnet - Note, Minimum is a /27"
  default     = null
}

variable "bastion_subnet_target_vnet_name" {
  type        = string
  description = "The name of the VNet the bastion is intended to join"
  default     = null
}

variable "bastion_subnet_target_vnet_rg_name" {
  type        = string
  description = "The name of the resource group that the VNet can be found in"
  default     = null
}

variable "copy_paste_enabled" {
  type        = bool
  description = "Whether copy paste is enabled, defaults to true"
  default     = true
}

variable "create_bastion_nsg" {
  type        = bool
  description = "Whether a NSG should be created for the Bastion, defaults to true"
  default     = true
}

variable "create_bastion_nsg_rules" {
  type        = bool
  description = "Whether the NSG rules for a bastion should be made, default is true"
  default     = true
}

variable "create_bastion_subnet" {
  type        = bool
  description = "Whether this module should create the bastion subnet for the user, defaults to true"
  default     = true
}

variable "external_subnet_id" {
  description = "The ID of the external subnet if not created by this module."
  type        = string
  default     = null
}

variable "file_copy_enabled" {
  type        = bool
  description = "Whether file copy is enabled"
  default     = null
}

variable "ip_connect_enabled" {
  type        = bool
  description = "Whether the IP connect feature is enabled"
  default     = null
}

variable "location" {
  type        = string
  description = "The location for the bastion host, default is UK South"
}

variable "rg_name" {
  type        = string
  description = "The resource group name for the Bastion resource"
}

variable "scale_units" {
  type        = number
  description = "The number of scale units, default is 2"
  default     = 2
}

variable "shareable_link_enabled" {
  type        = bool
  description = "Whether the shareable link is enabled"
  default     = null
}

variable "tags" {
  description = "The default tags to be assigned"
  type        = map(string)
}

variable "tunneling_enabled" {
  type        = bool
  description = "Whether the tunneling feature is enable"
  default     = null
}