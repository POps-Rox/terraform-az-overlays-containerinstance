# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_resource_group" "aci-network-rg" {
  name     = "aci-network-rg"
  location = var.location
  tags = {
    environment = "test"
  }
}

resource "azurerm_log_analytics_workspace" "aci-log" {
  depends_on = [
    azurerm_resource_group.aci-network-rg
  ]
  name                = "aci-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.aci-network-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}

module "aci-storage-account" {
  source = "github.com/POps-Rox/terraform-az-overlays-storageaccount"

  depends_on = [azurerm_resource_group.aci-network-rg]

  //Global Settings
  # Resource Group, location, VNet and Subnet details
  existing_resource_group_name = azurerm_resource_group.aci-network-rg.name
  location                     = var.location
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  environment                  = var.environment
  workload_name                = "dev-storage"

  # Locks
  enable_resource_locks = false

  # Tags
  # Adding TAG's to your Azure resources (Required)
  # Org Name and Env are already declared above, to use them here, create a variable. 
  add_tags = merge({}, {
    Example      = "basic"
    Organization = "AzureNoOps"
    Environment  = "dev"
    Workload     = "storage"
  }) # Tags to be applied to all resources
}

resource "azurerm_storage_share" "aci-storage-share" {
  name                 = "tools"
  storage_account_name = module.aci-storage-account.storage_account_name
  quota                = 5
}

module "aci-acr" {
  source = "github.com/POps-Rox/terraform-az-overlays-containerregistry"

  depends_on = [azurerm_resource_group.aci-network-rg]

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_container_registry_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  existing_resource_group_name  = azurerm_resource_group.aci-network-rg.name
  location                      = var.location
  environment                   = var.environment
  deploy_environment            = var.deploy_environment
  org_name                      = var.org_name
  workload_name                 = "dev-acr"
  sku                           = "Standard"
  public_network_access_enabled = true
  admin_enabled                 = true

  # Tags for Azure Resources
  add_tags = {
    foo = "bar"
  }
}
