resource "azapi_resource" "create_ssh_public_key" {
  name      = "manage_ssh_key"
  type      = "Microsoft.Compute/sshPublicKeys@2023-03-01"
  location  = var.location
  parent_id = azurerm_resource_group.dev_resource_group.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2023-03-01"
  resource_id = azapi_resource.create_ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

output "public_key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
}


resource "local_sensitive_file" "private_key" {
  content  = jsondecode(azapi_resource_action.ssh_public_key_gen.output).privateKey
  filename = "private_ssh_key_azure"
  file_permission = 600
}