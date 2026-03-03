output "shared_services_pips" {
  description = "Map of public ips of shared service objects, keyed by their map key"
  value = azurerm_public_ip.this
}

output "azure_bastion" {
  description = "Map of Azure Bastion objects, keyed by their map key"
  value = azurerm_bastion_host.this
}

output "azure_firewall" {
  description = "Map of Azure Firewall objects, keyed by their map key"
  value = azurerm_firewall.this
}