mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "generated-aci"
    }
  }
}

variables {
  location                     = "westus2"
  environment                  = "public"
  deploy_environment           = "dev"
  workload_name                = "api"
  org_name                     = "popsrox"
  existing_resource_group_name = "rg-existing"
  containers_config = [{
    name   = "app"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = 0.5
    memory = 1.5
    ports = [{
      port     = 80
      protocol = "TCP"
    }]
  }]
}

run "custom_name_public_container" {
  command = plan

  variables {
    custom_azure_container_instance_name = "custom-aci"
    dns_name_label                       = "custom-dns"
    add_tags = {
      env   = "tag-override"
      owner = "platform"
    }
  }

  override_module {
    target = module.mod_azure_region_lookup
    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  override_data {
    target = data.azurerm_resource_group.rgrp[0]
    values = {
      name     = "rg-existing"
      location = "eastus"
    }
  }

  override_data {
    target = data.popsrox_resource_name.aci
    values = {
      result = "generated-aci"
    }
  }

  assert {
    condition     = azurerm_container_group.aci.name == "custom-aci"
    error_message = "custom_azure_container_instance_name must take precedence over the generated name."
  }

  assert {
    condition     = azurerm_container_group.aci.ip_address_type == "Public" && azurerm_container_group.aci.dns_name_label == "custom-dns"
    error_message = "public containers must keep a public IP address and preserve the DNS label override."
  }

  assert {
    condition     = azurerm_container_group.aci.tags.env == "tag-override" && azurerm_container_group.aci.tags.owner == "platform" && azurerm_container_group.aci.tags.workload == "api"
    error_message = "container tags must merge defaults with caller tags, with caller tags taking precedence."
  }

  assert {
    condition     = azurerm_container_group.aci.location == "eastus"
    error_message = "container location must pass through from the selected resource group location."
  }

  assert {
    condition     = length(data.azurerm_resource_group.rgrp) == 1 && length(module.mod_scaffold_rg) == 0
    error_message = "create_resource_group=false must use the existing resource group data source and skip the scaffold module."
  }
}

run "empty_custom_name_falls_through" {
  command = plan

  variables {
    custom_azure_container_instance_name = ""
  }

  override_module {
    target = module.mod_azure_region_lookup
    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  override_data {
    target = data.azurerm_resource_group.rgrp[0]
    values = {
      name     = "rg-existing"
      location = "eastus"
    }
  }

  override_data {
    target = data.popsrox_resource_name.aci
    values = {
      result = "generated-aci"
    }
  }

  assert {
    condition     = azurerm_container_group.aci.name == "generated-aci"
    error_message = "empty custom_azure_container_instance_name must fall through to the generated name."
  }
}

run "private_vnet_container" {
  command = plan

  variables {
    vnet_integration_enabled = true
    subnet_ids               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"]
  }

  override_module {
    target = module.mod_azure_region_lookup
    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  override_data {
    target = data.azurerm_resource_group.rgrp[0]
    values = {
      name     = "rg-existing"
      location = "eastus"
    }
  }

  override_data {
    target = data.popsrox_resource_name.aci
    values = {
      result = "generated-aci"
    }
  }

  assert {
    condition     = azurerm_container_group.aci.ip_address_type == "Private" && contains(azurerm_container_group.aci.subnet_ids, var.subnet_ids[0])
    error_message = "vnet_integration_enabled=true must create a private container group on the supplied subnet."
  }

  assert {
    condition     = azurerm_container_group.aci.dns_name_label == null && azurerm_container_group.aci.dns_name_label_reuse_policy == null
    error_message = "private container groups must not set public DNS label arguments."
  }
}

run "created_resource_group_path" {
  command = plan

  variables {
    create_resource_group        = true
    existing_resource_group_name = null
    custom_resource_group_name   = ""
  }

  override_module {
    target = module.mod_azure_region_lookup
    outputs = {
      location_cli   = "westus2"
      location_short = "wus2"
    }
  }

  override_module {
    target = module.mod_scaffold_rg[0]
    outputs = {
      resource_group_name     = "generated-rg"
      resource_group_location = "westus2"
    }
  }

  override_data {
    target = data.popsrox_resource_name.aci
    values = {
      result = "generated-aci"
    }
  }

  assert {
    condition     = length(data.azurerm_resource_group.rgrp) == 0 && length(module.mod_scaffold_rg) == 1
    error_message = "create_resource_group=true must skip the existing resource group data source and enable the scaffold module."
  }

  assert {
    condition     = azurerm_container_group.aci.resource_group_name == "generated-rg" && azurerm_container_group.aci.location == "westus2"
    error_message = "created resource group outputs must drive the container group name and location."
  }
}
