resource "azurerm_policy_assignment" "allowed-loc-policy-ass" {
  name = "allowed-loc-policy-ass"
  scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  policy_definition_id = "${azurerm_policy_definition.AllowedLocationsPolicyDef.id}"
  description = "Restict deployment locations"
  display_name = "NaaS Deployment location restrictions"
}

resource "azurerm_policy_assignment" "allowed-vmsku-ass" {
  name = "allowed-vmsku-ass"
  scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
  description = "Limit the VM Skus allowed for deployment"
  display_name = "NaaS Allowed VM Skus"
  parameters = <<EOH
    {
        "listOfAllowedSkus": {
            "value": [
                "Standard_DS1_v2",
                "Standard_DS2_v2",
                "Standard_DS3_v2",
                "Standard_DS4_v2",
                "Standard_DS5_v2",
                "Standard_DS2_v2_Promo",
                "Standard_DS3_v2_Promo",
                "Standard_DS4_v2_Promo",
                "Standard_DS5_v2_Promo"
            ]
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "audit-unman-disks-ass" {
  name = "audit-unman-disks-ass"
  scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  description = "Audit the use of unmanaged disks"
  display_name = "Audit Unmanaged Disks"
}

resource "azurerm_policy_assignment" "deny-unmanaged-disks-assignment" {
  name                 = "deny-unman-disks-ass"
  display_name         = "Deny the creation of unmanaged disks"
  policy_definition_id = azurerm_policy_definition.deny-unmanaged-disks-def.id
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Deny the creation of unmanaged disks"
}

resource "azurerm_policy_assignment" "naming-conv-ass" {
  name                 = "naming-conv-ass"
  display_name         = "NaaS Enforce Naming Convention"
  policy_definition_id = azurerm_policy_definition.naming-convention-def.id
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Enforce the NaaS naming convention"
}

resource "azurerm_policy_assignment" "enforce-rg-tag-ass" {
  for_each             = var.rg_tags
  name                 = "enf-rgtag-${each.key}-ass"
  display_name         = "NaaS Enforce Required Tag ${each.key} on RG"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Enforce required tag ${each.key} on RGs"

  parameters = <<EOH
    {
        "tagName": {
            "value": "${each.key}"
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "append-rg-tag-ass" {
  for_each             = var.rg_tags
  name                 = "app-rgtag-${each.key}-ass"
  display_name         = "NaaS Append Required Tags ${each.key}:${each.value} to RG"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/49c88fc8-6fd1-46fd-a676-f12d1d3a4c71"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Append required tag ${each.key}:${each.value} to RG"

  parameters = <<EOH
    {
        "tagName": {
            "value": "${each.key}"
        },
        "tagValue": {
            "value": "${each.value}"
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "vm-storage-sku-ass" {
  name                 = "vm-storage-sku-ass"
  display_name         = "NaaS Enforce VM Storage SKU"
  policy_definition_id = azurerm_policy_definition.naming-convention-def.id
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Enforce VM Storage SKU to comply with NaaS requirements"
}

resource "azurerm_policy_assignment" "append-global-tag-ass" {
  for_each             = var.tags
  name                 = "app-globaltag-ass"
  display_name         = "NaaS Append Required Tags to all resources"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Append required tag to all resources"

  parameters = <<EOH
    {
        "tagName": {
            "value": "${each.key}"
        },
        "tagValue": {
            "value": "${each.value}"
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "audit-global-tag-ass" {
  for_each             = var.tags
  name                 = "audit-globaltag-ass"
  display_name         = "NaaS Require tag and its value"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Enforces a required tag and its value. Does not apply to resource groups."

  parameters = <<EOH
    {
        "tagName": {
            "value": "${each.key}"
        },
        "tagValue": {
            "value": "${each.value}"
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "audit-vm-without-dr" {
  name                 = "audit-vm-without-dr"
  display_name         = "Audit VM without DR configured"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Audit virtual machines without disaster recovery configured"
}

resource "azurerm_policy_assignment" "only-approved-vm-ext" {
  name                 = "only-approved-vm-ext"
  display_name         = "Only approved VM extensions should be installed" 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c0e996f8-39cf-4af9-9f45-83fbde810432"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "This policy governs the virtual machine extensions that are not approved."

  parameters = <<EOH
    {
      	"Effect": {
          "value": "Audit"
        },

        "approvedExtensions": {
          "value": [
            "Extension1",
            "extension2"
          ]
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "network-watcher-on-vnet-create" {
  name                 = "network-watcher-on-vnet-create"
  display_name         = "Deploy network watcher when virtual networks are created"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a9b99dd8-06c5-4317-8629-9d86a3c6e7d9"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "This policy creates a network watcher resource in regions with virtual networks. You need to ensure existence of a resource group named networkWatcherRG, which will be used to deploy network watcher instances."
}

resource "azurerm_policy_assignment" "network-watcher-enabled" {
  name                 = "network-watcher-enabled"
  display_name         = "Network Watcher should be enabled" 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b6e2945c-0b7b-40f5-9233-7a5323b5cdc6"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "Network Watcher is a regional service that enables you to monitor and diagnose conditions at a network scenario level in, to, and from Azure. Scenario level monitoring enables you to diagnose problems at an end to end network level view. Network diagnostic and visualization tools available with Network Watcher help you understand, diagnose, and gain insights to your network in Azure."

  parameters = <<EOH
    {
      	"listOfLocations": {
          "value": [
            "listoflocations",
            "location2"
          ]
        }
    }
  EOH
}

resource "azurerm_policy_assignment" "activity-log-one-year" {
  name                 = "activity-log-one-year"
  display_name         = "Activity log should be retained for at least one year" 
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b02aacc0-b073-424e-8298-42b22829ee0a"
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  description          = "This policy audits the activity log if the retention is not set for 365 days or forever (retention days set to 0)."

  parameters = <<EOH
    {
      	"effect": {
          "value": "AuditIfNotExists"
        }
    }
  EOH
}
