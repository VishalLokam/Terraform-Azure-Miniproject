variable "prefix" {
  type        = string
  description = "prefix to attach before each resource name"
}

variable "location" {
  type        = string
  description = "Azure region in which the resource will be created"
}

variable "username" {
  type        = string
  description = "Username for the VM"
  default     = "azureadmin"

}