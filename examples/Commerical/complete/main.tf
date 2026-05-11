# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_aci" {
  #source  = "github.com/POps-Rox/terraform-az-overlays-containerinstance"
  #version = "x.x.x"
  source = "../../.."

  depends_on = [azurerm_resource_group.aci-network-rg]

  # Resource Group, location, VNet and Subnet details
  existing_resource_group_name = azurerm_resource_group.aci-network-rg.name
  location                     = var.location
  deploy_environment           = var.deploy_environment
  environment                  = var.environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # Container Instance details
  os_type        = "Linux"
  restart_policy = "Always"

  log_analytics_workspace_id  = azurerm_log_analytics_workspace.aci-log.workspace_id
  log_analytics_workspace_key = azurerm_log_analytics_workspace.aci-log.primary_shared_key

  vnet_integration_enabled    = false
  dns_name_label              = null
  dns_name_label_reuse_policy = null
  subnet_ids                  = null

  # Container Group details
  containers_config = [
    {
      name   = "aci-example"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      cpu    = 1
      memory = 2

      ports = [{
        port     = 8080
        protocol = "TCP"
      }]

      environment_variables = {
        "MY_VARIABLE" = "value"
      }

      secure_environment_variables = {
        "SECURE_VARIABLE" = "secure_value"
      }

      volume = [
        {
          name       = "tools-volume"
          mount_path = "/aci/tools"

          storage_account_name = module.aci-storage-account.storage_account_name
          storage_account_key  = module.aci-storage-account.primary_access_key
          share_name           = azurerm_storage_share.aci-storage-share.name
        },
        {
          name       = "secret-volume"
          mount_path = "/aci/secrets"

          secret = {
            "secret.txt" = base64encode("supersecretvalue")
          }
        }
      ]
    }
  ]

  dns_config = null # Only supported when "vnet_integration_enabled" is "true"

  # Container Registry Details
  registry_credential = [{
    server   = module.aci-acr.login_server
    username = module.aci-acr.registry_username
    password = module.aci-acr.registry_password
  }]

  identity = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}
