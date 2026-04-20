<!-- BADGES:START -->
[![CI](https://github.com/POps-Rox/tf-az-overlays-containerinstance/actions/workflows/ci.yml/badge.svg)](https://github.com/POps-Rox/tf-az-overlays-containerinstance/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/POps-Rox/tf-az-overlays-containerinstance/pulls)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/POps-Rox/tf-az-overlays-containerinstance/graphs/commit-activity)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9-623CE4.svg?logo=terraform)](https://www.terraform.io)
<!-- BADGES:END -->

# Azure Container Instance Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/POps-Rox/overlays-container-instance/azurerm/)

This Overlay terraform module can deploys and manages a [Azure Container Instance Group](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-overview) This module can be used in a [SCCA compliant Network](https://registry.terraform.io/modules/POps-Rox/overlays-hubspoke/azurerm/latest).

## Using Azure Clouds

Since this module is built for both public and us government clouds. The `environment` variable defaults to `public` for Azure Cloud. When using this module with the Azure Government Cloud, you must set the `environment` variable to `usgovernment`. You will also need to set the azurerm provider `environment` variable to the proper cloud as well. This will ensure that the correct Azure Government Cloud endpoints are used. You will also need to set the `location` variable to a valid Azure Government Cloud location.

Example Usage for Azure Government Cloud:

```hcl

provider "azurerm" {
  environment = "usgovernment"
}

module "mod_ampls" {
  source  = "POps-Rox/tf-az-overlays-container-instance/azurerm"
  version = "x.x.x"
  
  location = "usgovvirginia"
  environment = "usgovernment"
  ...
}

```

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation](https://github.com/POps-Rox/tf-az-overlays-compute-image-gallery/blob/main).

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## License

This Terraform module is open-sourced software licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Resources Supported

- [Azure Container Instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group)

## Module Usage

```hcl
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_ampls" {
  source  = "POps-Rox/tf-az-overlays-container-instance/azurerm"
  version = "x.x.x"

  depends_on = [azurerm_virtual_network.example-vnet, azurerm_subnet.example-snet, azurerm_log_analytics_workspace.example-log]

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
  
  # Tags
  add_tags = {} # Tags to be applied to all resources
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_popsrox-utils"></a> [popsrox-utils](#requirement\_popsrox-utils) | ~> 1.0.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_popsrox-utils"></a> [popsrox-utils](#provider\_popsrox-utils) | ~> 1.0.4 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mod_azure_region_lookup"></a> [mod\_azure\_region\_lookup](#module\_mod\_azure\_region\_lookup) | POps-Rox/overlays-azregions-lookup/azurerm | ~> 1.0.0 |
| <a name="module_mod_scaffold_rg"></a> [mod\_scaffold\_rg](#module\_mod\_scaffold\_rg) | POps-Rox/overlays-resource-group/azurerm | ~> 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_group.aci](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [popsrox_resource_name.aci](https://registry.terraform.io/providers/POps-Rox/azutils/latest/docs/data-sources/resource_name) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_tags"></a> [add\_tags](#input\_add\_tags) | Map of custom tags. | `map(string)` | `{}` | no |
| <a name="input_containers_config"></a> [containers\_config](#input\_containers\_config) | Containers configurations. | <pre>list(object({<br>    name = string<br><br>    image  = string<br>    cpu    = number<br>    memory = number<br><br>    environment_variables        = optional(map(string))<br>    secure_environment_variables = optional(map(string))<br>    commands                     = optional(list(string))<br><br>    ports = list(object({<br>      port     = number<br>      protocol = string<br>    }))<br><br>    volume = optional(list(object({<br>      name                 = string<br>      mount_path           = string<br>      read_only            = optional(bool)<br>      empty_dir            = optional(bool)<br>      storage_account_name = optional(string)<br>      storage_account_key  = optional(string)<br>      share_name           = optional(string)<br>      secret               = optional(map(any))<br>    })), [])<br><br>    readiness_probe = optional(object({<br>      exec = optional(list(string))<br>      http_get = optional(object({<br>        path         = optional(string)<br>        port         = optional(number)<br>        scheme       = optional(string)<br>        http_headers = optional(map(string))<br>      }))<br>      initial_delay_seconds = optional(number)<br>      period_seconds        = optional(number)<br>      failure_threshold     = optional(number)<br>      success_threshold     = optional(number)<br>      timeout_seconds       = optional(number)<br>    }))<br><br>    liveness_probe = optional(object({<br>      exec = optional(list(string))<br>      http_get = optional(object({<br>        path         = optional(string)<br>        port         = optional(number)<br>        scheme       = optional(string)<br>        http_headers = optional(map(string))<br>      }))<br>      initial_delay_seconds = optional(number)<br>      period_seconds        = optional(number)<br>      failure_threshold     = optional(number)<br>      success_threshold     = optional(number)<br>      timeout_seconds       = optional(number)<br>    }))<br><br>  }))</pre> | n/a | yes |
| <a name="input_create_private_endpoint_subnet"></a> [create\_private\_endpoint\_subnet](#input\_create\_private\_endpoint\_subnet) | Controls if the subnet should be created. If set to false, the subnet name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_custom_azure_container_instance_name"></a> [custom\_azure\_container\_instance\_name](#input\_custom\_azure\_container\_instance\_name) | The name of the custom Azure Container Instance to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_custom_resource_group_name"></a> [custom\_resource\_group\_name](#input\_custom\_resource\_group\_name) | The name of the custom resource group to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_default_tags_enabled"></a> [default\_tags\_enabled](#input\_default\_tags\_enabled) | Option to enable or disable default tags. | `bool` | `true` | no |
| <a name="input_deploy_environment"></a> [deploy\_environment](#input\_deploy\_environment) | Name of the workload's environment | `string` | n/a | yes |
| <a name="input_dns_config"></a> [dns\_config](#input\_dns\_config) | DNS configuration to apply to containers. | <pre>object({<br>    nameservers    = list(string)<br>    search_domains = optional(list(string))<br>    options        = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_dns_name_label"></a> [dns\_name\_label](#input\_dns\_name\_label) | ACI Custom DNS name label used when container is public. | `string` | `null` | no |
| <a name="input_dns_name_label_reuse_policy"></a> [dns\_name\_label\_reuse\_policy](#input\_dns\_name\_label\_reuse\_policy) | The value representing the security enum. Noreuse, ResourceGroupReuse, SubscriptionReuse, TenantReuse or Unsecure. Defaults to Unsecure. | `string` | `"Unsecure"` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Manages a Private Endpoint to Azure Container Registry. Default is false. | `bool` | `false` | no |
| <a name="input_enable_resource_locks"></a> [enable\_resource\_locks](#input\_enable\_resource\_locks) | (Optional) Enable resource locks, default is false. If true, resource locks will be created for the resource group and the storage account. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The Terraform backend environment e.g. public or usgovernment | `string` | n/a | yes |
| <a name="input_existing_private_dns_zone"></a> [existing\_private\_dns\_zone](#input\_existing\_private\_dns\_zone) | Name of the existing private DNS zone | `any` | `null` | no |
| <a name="input_existing_private_subnet_name"></a> [existing\_private\_subnet\_name](#input\_existing\_private\_subnet\_name) | Name of the existing subnet for the private endpoint | `any` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of the existing resource group to use. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Map with identity block information. | <pre>object({<br>    type         = optional(string, "SystemAssigned")<br>    identity_ids = optional(list(string))<br>  })</pre> | `{}` | no |
| <a name="input_init_containers"></a> [init\_containers](#input\_init\_containers) | initContainer configuration. | <pre>list(object({<br>    name                         = string<br>    image                        = string<br>    environment_variables        = optional(map(string), {})<br>    secure_environment_variables = optional(map(string), {})<br>    commands                     = optional(list(string), [])<br>    volume = optional(list(object({<br>      name                 = string<br>      mount_path           = string<br>      read_only            = optional(bool)<br>      empty_dir            = optional(bool)<br>      storage_account_name = optional(string)<br>      storage_account_key  = optional(string)<br>      share_name           = optional(string)<br>      secret               = optional(map(any))<br>    })), [])<br>    security = optional(object({<br>      privilege_enabled = bool<br>    }), null)<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which instance will be hosted | `string` | n/a | yes |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | (Optional) id locks are enabled, Specifies the Level to be used for this Lock. | `string` | `"CanNotDelete"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The workspace (customer) ID of the Log Analytics workspace to send diagnostics to. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_key"></a> [log\_analytics\_workspace\_key](#input\_log\_analytics\_workspace\_key) | The shared key of the Log Analytics workspace to send diagnostics to. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Name of the organization | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The OS for the container group. Allowed values are Linux and Windows. Changing this forces a new resource to be created. | `string` | `"Linux"` | no |
| <a name="input_private_subnet_address_prefix"></a> [private\_subnet\_address\_prefix](#input\_private\_subnet\_address\_prefix) | The name of the subnet for private endpoints | `any` | `null` | no |
| <a name="input_registry_credential"></a> [registry\_credential](#input\_registry\_credential) | A registry\_credential object as documented below. Changing this forces a new resource to be created. | <pre>list(object({<br>    server                    = string<br>    username                  = optional(string)<br>    password                  = optional(string) # TODO: mark as sensitive (hashicorp/terraform#32414)<br>    user_assigned_identity_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_restart_policy"></a> [restart\_policy](#input\_restart\_policy) | Restart policy for the container group. Allowed values are `Always`, `Never`, `OnFailure`. Changing this forces a new resource to be created. | `string` | `"Always"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs of the private network profile of the container.<br>Mandatory when VNet integration is enabled. | `list(string)` | `null` | no |
| <a name="input_use_location_short_name"></a> [use\_location\_short\_name](#input\_use\_location\_short\_name) | Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored. | `bool` | `true` | no |
| <a name="input_use_naming"></a> [use\_naming](#input\_use\_naming) | Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `false` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network for the private endpoint | `any` | `null` | no |
| <a name="input_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#input\_vnet\_integration\_enabled) | Allow to enable Vnet integration. | `bool` | `false` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Name of the workload\_name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aci_fqdn"></a> [aci\_fqdn](#output\_aci\_fqdn) | The FQDN of the container group derived from `dns_name_label`. |
| <a name="output_aci_id"></a> [aci\_id](#output\_aci\_id) | Azure container instance group ID |
| <a name="output_aci_identity_principal_id"></a> [aci\_identity\_principal\_id](#output\_aci\_identity\_principal\_id) | ACI identity principal ID. |
| <a name="output_aci_ip_address"></a> [aci\_ip\_address](#output\_aci\_ip\_address) | The IP address allocated to the container instance group. |
<!-- END_TF_DOCS -->