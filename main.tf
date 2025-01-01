#defining the Resource Group Hybrid-RG
resource "azurerm_resource_group" "Hybrid-RG" {

    name = local.resource_groups_name
    location = local.location
}

#Defining the Spoke Vnet
resource "azurerm_virtual_network" "Vnet01" {

    name = local.virtual_networks[0].name
    resource_group_name = local.resource_groups_name
    location = local.location
    address_space = local.virtual_networks[0].address_space

    depends_on = [ azurerm_resource_group.Hybrid-RG ]  
}

#defining the Hub Vnet
resource "azurerm_virtual_network" "Vnet02" {

    name = local.virtual_networks[1].name
    resource_group_name = local.resource_groups_name
    location = local.location
    address_space = local.virtual_networks[1].address_space

    depends_on = [ azurerm_resource_group.Hybrid-RG ]
}

#defining the Onprem-Vnet
resource "azurerm_virtual_network" "Vnet03" {

    name = local.virtual_networks[2].name
    resource_group_name = local.resource_groups_name
    location = local.location
    address_space = local.virtual_networks[2].address_space

    depends_on = [ azurerm_resource_group.Hybrid-RG ]
  
}

#defining the Spoke Workload Subnet
resource "azurerm_subnet" "Workload-Spoke-Subnet" {

    name = local.subnets[0].name
    resource_group_name = local.resource_groups_name
    virtual_network_name = local.virtual_networks[0].name
    address_prefixes =  [local.subnets[0].address_prefix]

    depends_on = [ azurerm_virtual_network.Vnet01]
  
}


#defing the GatewaySubnet for Hybrid Network
resource "azurerm_subnet" "hybridgatewaysubnet" {

    name = local.subnets[1].name
    resource_group_name = local.resource_groups_name
    virtual_network_name = local.virtual_networks[1].name
    address_prefixes = [local.subnets[1].address_prefix]

    depends_on = [ azurerm_virtual_network.Vnet02 ]

}

#defining the AzureFirewallSubnet for Hybrid Network
resource "azurerm_subnet" "hybridfwsubnet" {

    name = local.subnets[2].name
    resource_group_name = local.resource_groups_name
    virtual_network_name = local.virtual_networks[1].name
    address_prefixes = [local.subnets[2].address_prefix]

    depends_on = [ azurerm_virtual_network.Vnet02 ]
  
}

#defining the Onprem Subnet 
resource "azurerm_subnet" "Onpremworkloadsubnet" {

    name = local.subnets[3].name
    resource_group_name = local.resource_groups_name
    virtual_network_name = local.virtual_networks[2].name
    address_prefixes = [local.subnets[3].address_prefix]

    depends_on = [ azurerm_virtual_network.Vnet03 ]
  
}

#defining the GatewaySubnet for On-Prem Workload
resource "azurerm_subnet" "Onpremgatewaysubnet" {

    name = local.subnets[4].name
    resource_group_name = local.resource_groups_name
    virtual_network_name = local.virtual_networks[2].name
    address_prefixes = [local.subnets[4].address_prefix]

    depends_on = [ azurerm_virtual_network.Vnet03 ]
  
}

#deploying the Public IP
resource "azurerm_public_ip" "hub-gw-pip" {
  name                = "hub-gw-pip"
  resource_group_name = local.resource_groups_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.Hybrid-RG ]
}

#deploying the Public IP
resource "azurerm_public_ip" "Onprem-gw-pip" {
  name                = "onprem-gw-pip"
  resource_group_name = local.resource_groups_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.Hybrid-RG ]
}

#deploying the virtual network Gateway for OnPrem Network
resource "azurerm_virtual_network_gateway" "onprem_gateway" {
  name                = "onprem-GW"
  location            = local.location
  resource_group_name = local.resource_groups_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  enable_bgp          = false
  sku                 = "VpnGw2"
  ip_configuration {
    name                          = "onprem-gateway-pip"
    public_ip_address_id          = azurerm_public_ip.Onprem-gw-pip.id
    subnet_id                     = azurerm_subnet.Onpremgatewaysubnet.id
  }

  depends_on = [ azurerm_subnet.Onpremgatewaysubnet ]
}

#deploying the virtual network Gateway for Hybrid Network
resource "azurerm_virtual_network_gateway" "hub_gateway" {
  name                = "Hub-GW"
  location            = local.location
  resource_group_name = local.resource_groups_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  enable_bgp          = false
  sku                 = "VpnGw2"
  ip_configuration {
    name                          = "hub-gateway-pip"
    public_ip_address_id          = azurerm_public_ip.hub-gw-pip.id
    subnet_id                     = azurerm_subnet.hybridgatewaysubnet.id
  }

  depends_on = [ azurerm_subnet.hybridgatewaysubnet ]
}

#virtual_network_gateway_connection_hub-to-onprem
resource "azurerm_virtual_network_gateway_connection" "hub-to-onprem" {
  name                = "hub-to-onprem"
  location            = local.location
  resource_group_name = local.resource_groups_name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_gateway.id

  shared_key = "ishan@2210"

  timeouts {
    create = "60m"  # Extend creation timeout to 60 minutes
    delete = "30m"
  }

  depends_on = [ azurerm_virtual_network_gateway.hub_gateway ]
}

#virtual_network_gateway_connection-onprem-to-hub
resource "azurerm_virtual_network_gateway_connection" "onprem-to-hub" {
  name                = "onprem-to-hub"
  location            = local.location
  resource_group_name = local.resource_groups_name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_gateway.id

  shared_key = "ishan@2210"
  timeouts {
    create = "60m"  # Extend creation timeout to 60 minutes
    delete = "30m"
  }
  depends_on = [ azurerm_subnet.Onpremgatewaysubnet] 
}

#hub vnet peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.Hybrid-RG.name
  virtual_network_name      = azurerm_virtual_network.Vnet02.name
  remote_virtual_network_id = azurerm_virtual_network.Vnet01.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

 timeouts {
    create = "20m"
  }

  depends_on = [ azurerm_virtual_network.Vnet01,azurerm_virtual_network.Vnet02 ]
}
#spoke vnet peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.Hybrid-RG.name
  virtual_network_name      = azurerm_virtual_network.Vnet01.name
  remote_virtual_network_id = azurerm_virtual_network.Vnet02.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
   timeouts {
    create = "20m"
  }
  depends_on = [ azurerm_virtual_network.Vnet01, azurerm_virtual_network.Vnet02 ]
}

#nic01 for spoke vm
resource "azurerm_network_interface" "spokevm-nic01" {
  name                = "spokevm-nic01"
  location            = local.location
  resource_group_name = local.resource_groups_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Workload-Spoke-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.spokevm-pip01.id
  }
}

#nic01 for onprem vm
resource "azurerm_network_interface" "onprem-vm-nic01" {
  name                = "onprem-nic01"
  location            = local.location
  resource_group_name = local.resource_groups_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     =  azurerm_subnet.Onpremworkloadsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.onprem-pip01.id
  }
}

#defininig the PublicIP Addresses for spokevm
resource "azurerm_public_ip" "spokevm-pip01" {
  name                = "spokevm-pip01"
  resource_group_name = local.resource_groups_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.Hybrid-RG]
}


#defininig the PublicIP Addresses for spokevm
resource "azurerm_public_ip" "onprem-pip01" {
  name                = "onprem-pip01"
  resource_group_name = local.resource_groups_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.Hybrid-RG]
}

#defining the NSG for Spoke VM
resource "azurerm_network_security_group" "spokevm-nsg01" {
  name                = "spokevm-nsg01"
  location            = local.location
  resource_group_name = local.resource_groups_name

  security_rule {
    name                       = "AllowallInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  depends_on = [ azurerm_resource_group.Hybrid-RG ]
}

#defining the NSG for Onprem VVM
resource "azurerm_network_security_group" "onprem-nsg01" {
  name                = "onprem-nsg01"
  location            = local.location
  resource_group_name = local.resource_groups_name

  security_rule {
    name                       = "AllowallInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  depends_on = [ azurerm_resource_group.Hybrid-RG ]
}

#assiging NIC with NSG for Onprem vm
resource "azurerm_network_interface_security_group_association" "onprem-nsg01association" {
  network_interface_id      = azurerm_network_interface.onprem-vm-nic01.id
  network_security_group_id = azurerm_network_security_group.onprem-nsg01.id
}

#assiging NIC with NSG for Spoke vm
resource "azurerm_network_interface_security_group_association" "spokevm-nsg01association" {
  network_interface_id      = azurerm_network_interface.spokevm-nic01.id
  network_security_group_id = azurerm_network_security_group.spokevm-nsg01.id
}

#defining the vm for Spoke 
resource "azurerm_windows_virtual_machine" "spoke-vm01" {
  name                = local.virtual_machines_names[0].name
  resource_group_name = local.resource_groups_name
  location            = local.location
  size                = var.vm_sizes
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.spokevm-nic01.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
  depends_on = [ azurerm_network_interface.spokevm-nic01, azurerm_resource_group.Hybrid-RG ]
}

resource "azurerm_windows_virtual_machine" "onprem-vm01" {
  name                = local.virtual_machines_names[1].name
  resource_group_name = local.resource_groups_name
  location            = local.location
  size                = var.vm_sizes
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.onprem-vm-nic01.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
  depends_on = [ azurerm_network_interface.spokevm-nic01, azurerm_resource_group.Hybrid-RG ]
}

#defining the public ip for firewall
resource "azurerm_public_ip" "fw-pip01" {
  name                = "fw-pip"
  location            = local.location
  resource_group_name = azurerm_resource_group.Hybrid-RG.name
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [ azurerm_resource_group.Hybrid-RG ]
}

#defining the firewall
resource "azurerm_firewall" "az-fw" {
  name                = "az-fw"
  location            = local.location
  resource_group_name = azurerm_resource_group.Hybrid-RG.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hybridfwsubnet.id
    public_ip_address_id = azurerm_public_ip.fw-pip01.id

  }
  depends_on = [ azurerm_subnet.hybridfwsubnet, azurerm_public_ip.fw-pip01 ]
}

#adding nat rule collection
resource "azurerm_firewall_nat_rule_collection" "spokerdpnat" {
  name                = "hybridrules"
  azure_firewall_name = azurerm_firewall.az-fw.name
  resource_group_name = azurerm_resource_group.Hybrid-RG.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "rdpnat01"

    source_addresses = [
      "*"
    ]

    destination_ports = [
      "7890",
    ]

    destination_addresses = [
      azurerm_public_ip.fw-pip01.ip_address
    ]

    translated_port = 3389

    translated_address = "20.0.0.4"

    protocols = [
      "TCP",
      "UDP",
    ]
  }
   timeouts {
    create = "30m"  # Set a timeout of 30 minutes
    update = "30m"
  }
  depends_on = [ azurerm_firewall.az-fw ]
}

#adding network rule collection for RDP and HTTP
resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "networkrulecollection01"
  azure_firewall_name = azurerm_firewall.az-fw.name
  resource_group_name = azurerm_resource_group.Hybrid-RG.name
  priority            = 110
  action              = "Allow"
   rule {
    name = "allowhttp"

    source_addresses = [
      "50.0.0.0/16",
    ]

    destination_ports = [
      "80",
    ]

    destination_addresses = [
      "20.0.0.0/16",
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
  rule {
    name = "allowrdp"

    source_addresses = [
      "50.0.0.0/16",
    ]

    destination_ports = [
      "3389",
    ]

    destination_addresses = [
      "20.0.0.0/16",
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
   timeouts {
    create = "30m"
    update = "30m"
  }
  depends_on = [ azurerm_firewall.az-fw ]
}

#spoke-to-internet route table
resource "azurerm_route_table" "spokert-to-internet" {
  name                = "spokert-to-internet"
  location            = local.location
  resource_group_name = azurerm_resource_group.Hybrid-RG.name

  route {
    name           = "routespoke01"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  depends_on = [ azurerm_virtual_network.Vnet01,azurerm_subnet.hybridfwsubnet,azurerm_firewall.az-fw ]

}

resource "azurerm_route_table" "hubgw-to-spoke" {
  name                = "hubgw-to-spoke"
  location            = local.location
  resource_group_name = azurerm_resource_group.Hybrid-RG.name

  route {
    name           = "routehubgw01"
    address_prefix = "20.0.0.0/16"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }
  depends_on = [ azurerm_virtual_network.Vnet01,azurerm_subnet.hybridfwsubnet,azurerm_firewall.az-fw ]
}

#route_table_association_with_spokesubnet
resource "azurerm_subnet_route_table_association" "spokert01" {
  subnet_id      = azurerm_subnet.Workload-Spoke-Subnet.id
  route_table_id = azurerm_route_table.spokert-to-internet.id

}

#route_table_association_with_hybridgatewaysubnet
resource "azurerm_subnet_route_table_association" "hubgw-to-spoke" {
  subnet_id      = azurerm_subnet.hybridgatewaysubnet.id
  route_table_id = azurerm_route_table.hubgw-to-spoke.id
}













