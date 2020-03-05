# Allowed Deployment Locations Policy

resource "azurerm_policy_definition" "AllowedLocationsPolicyDef" {
  name = "allowed-regions-policy-def"
  policy_type = "Custom"
  mode = "Indexed"
  display_name = "NaaS Allowed Deployment Regions"
  management_group_id = var.management_group_id

  policy_rule = <<EOH
    {
        "if": {
            "anyOf": [
                {
                    "allOf": [
                        {
                            "field": "location",
                            "notIn": [
                                "USDoD East",
                                "USDoD Central"
                            ]
                        },
                        {
                            "field": "location",
                            "notEquals": "global"
                        },
                        {
                            "field": "type",
                            "notEquals": "Microsoft.AzureActiveDirectory/b2cDirectories"
                        },
                        {
                            "field": "type",
                            "notLike": "Microsoft.Automation/*"
                        }
                    ]
                },
                {
                    "allOf": [
                        {
                            "field": "location",
                            "notIn": [
                                "USGov Virginia"
                            ]
                        },
                        {
                            "field": "type",
                            "like": "Microsoft.Automation/*"
                        }
                    ]
                }
            ]
        },
        "then": {
            "effect": "deny"
        }
    }
  EOH
}


# Deny creation of unmanaged disks

resource "azurerm_policy_definition" "deny-unmanaged-disks-def" {
  name                = "deny-unmanaged-disks-def"
  display_name        = "NaaS Deny creation of unmanaged VM disks"
  mode                = "All"
  policy_type         = "Custom"
  description         = "Deny the creation of unmanaged disks"
  management_group_id = var.management_group_id

  policy_rule = <<EOH
    {
        "if": {
            "anyOf": [
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Compute/virtualMachines"
                        },
                        {
                            "field": "Microsoft.Compute/virtualMachines/osDisk.uri",
                            "exists": "True"
                        }
                    ]
                },
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Compute/VirtualMachineScaleSets"
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "Microsoft.Compute/VirtualMachineScaleSets/osDisk.vhdContainers",
                                    "exists": "True"
                                },
                                {
                                    "field": "Microsoft.Compute/VirtualMachineScaleSets/osdisk.imageUrl",
                                    "exists": "True"
                                }
                            ]
                        }
                    ]
                }
            ]
        },
        "then": {
            "effect": "deny"
        }
    }
  EOH
}


# Enforce NaaS Naming conventions

resource "azurerm_policy_definition" "naming-convention-def" {
  name                = "naming-convention-def"
  display_name        = "NaaS Enforce Naming Conventions"
  mode                = "All"
  policy_type         = "Custom"
  description         = "Enforce the naming conventions required by USAF"
  management_group_id = var.management_group_id

  policy_rule = <<EOH
    {
        "if": {
            "anyOf": [
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Resources/subscriptions/resourceGroups"
                        },
                        {
                            "field": "name",
                            "match": "az-????-rsgrg-?####-USDoDEast-*"
                        }
                    ]
                },
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Compute/virtualMachines"
                        },
                        {
                            "field": "name",
                            "match": "az-????-vm-?####-USDoDEast-*"
                        }
                    ]
                },
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Storage/storageAccounts"
                        },
                        {
                            "field": "name",
                            "match": "az-????-strge-?####-USDoDEast-*"
                        }
                    ]
                }
            ]
        },
        "then": {
            "effect": "deny"
        }
    }
  EOH
}


# Enforce correct storage SKU

resource "azurerm_policy_definition" "vm-storage-sku-def" {
  name                = "vm-storage-sku-def"
  display_name        = "NaaS Enforce VM Storage SKU"
  mode                = "All"
  policy_type         = "Custom"
  description         = "Enforce the proper VM Storage SKU for Managed Disks"
  management_group_id = var.management_group_id

  policy_rule = <<EOH
    {
        "if": {
            "anyOf": [
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.managedDisk.storageAccountType"        
                        },
                        {
                            "field": "name",
                            "notEquals": "StandardSSD_LRS"
                        }
                    ]
                },
                {
                    "allOf": [
                        {
                            "field": "type",
                            "equals": "Microsoft.Compute/disks"
                        },
                        {
                            "field": "Microsoft.Compute/disks/sku.name",
                            "notIn": [
                                "${var.allowed_managed_disk_skus}"
                            ]
                        }
                    ]
                }
            ]
        },
        "then": {
            "effect": "deny"
        }
    }
  EOH
}