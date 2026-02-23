output "resource_groups" {
    value = {
        for k, v in module.resource_groups.resource_groups : k => {
            name = v.name
        }
    }
}

output "virtual_networks" {
    value = {
        for k, v in module.virtual_networks.virtual_networks : k => {
            network_name = v.name
            network_subnets = v.subnet[*].name
        }
    }
}