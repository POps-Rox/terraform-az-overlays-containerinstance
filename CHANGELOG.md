# Changelog

## [v2.0.0] - Phase 1 azurerm 4.x upgrade

### Changed (BREAKING)
- Raised `required_version` from `>= 1.9` to `>= 1.10`
- Raised `azurerm` provider constraint from `~> 3.116` to `~> 4.20`
- Added `azapi ~> 2.0` to `required_providers` for fleet alignment
- All `examples/**/versions.tf` files updated with matching constraints

### Migration codemods applied
- `azurerm_subnet.private_endpoint_network_policies_enabled = true` →
  `azurerm_subnet.private_endpoint_network_policies = "Enabled"` in
  `resources.template.private.endpoints.tf` (4.x renamed the bool argument
  to a string enum with values `Enabled`/`Disabled`/`NetworkSecurityGroupEnabled`/`RouteTableEnabled`).

### Notes
- No `azurerm_monitor_diagnostic_setting` resources declared in this overlay,
  so no `retention_policy` block removal was required.
- No `enable_https_traffic_only` / `allow_blob_public_access` /
  `enable_rbac_authorization` attributes present.
- `azurerm` 4.x requires `ARM_SUBSCRIPTION_ID` (or `subscription_id` in the
  `provider "azurerm"` block) at apply time. Examples leave the provider block
  bare so consumers can drive subscription via env var.
- Validation: root + 3 of 4 examples returned `Success! The configuration is valid.`
  with `azurerm v4.42.0`, `azapi v2.9.0`, `popsrox v1.0.9` resolved at validation time.
  The `complete` example pulls in sibling overlays (`terraform-az-overlays-storageaccount`,
  `terraform-az-overlays-containerregistry`) that are still on `azurerm ~> 3.116`; it
  will validate cleanly once those companion PRs merge.

## [Unreleased]

### Changed
- Updated `required_version` from `>= 1.3` to `>= 1.9`
- Updated `azurerm` provider constraint from `~> 3.22` to `~> 3.116`
- Added `terraform {}` blocks with version constraints to all 4 example `versions.tf` files
