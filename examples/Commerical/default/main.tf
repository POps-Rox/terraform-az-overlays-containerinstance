# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_aci" {
  #source  = "github.com/POps-Rox/terraform-az-overlays-containerinstance"
  #version = "x.x.x"
  source = "../../.."

  # Resource Group, location, VNet and Subnet details
  create_resource_group = true
  location              = var.location
  deploy_environment    = var.deploy_environment
  environment           = var.environment
  org_name              = var.org_name
  workload_name         = var.workload_name

  # Container Instance details
  restart_policy = "OnFailure"

  # Container Group details
  containers_config = [
    {
      name   = "aci-example"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      cpu    = 1
      memory = 2

      ports = [{
        port     = 80
        protocol = "TCP"
      }]
    }
  ]
}
