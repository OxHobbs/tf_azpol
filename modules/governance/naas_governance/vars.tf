variable "management_group_id" {
  description = "The ID of the management group to which the Azure policies will be applied"
  type        = string
}

variable "rg_tags" {
  description = "The tags that are required on Resource Groups"
  type = map(string)
}

variable "allowed_managed_disk_skus" {
  description = "A list of the allowed managed disks SKUs"
  type = string
}

variable "tags" {
  description = "the tags that are required on all resources"
  type = map(string)
}
