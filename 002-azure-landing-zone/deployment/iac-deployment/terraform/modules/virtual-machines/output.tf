output "network_interfaces" {
  description = "Map of network interface objects, keyed by their map key"
  value       = azurerm_network_interface.this
}

output "linux_virtual_machines" {
  description = "Map of linux virtual machine objects, keyed by their map key"
  value       = azurerm_linux_virtual_machine.this
}