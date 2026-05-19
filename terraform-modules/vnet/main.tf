resource "azurerm_virtual_network" "dkart-vnet" {
  name                = "dkart-dev-network"
  location            = "East US"
  resource_group_name = var.rg-name
  address_space       = var.cidr-for-vnet

}

resource "azurerm_subnet" "public-subnet" {
  name                 = "dkart-public-subnet"
  resource_group_name  =  var.rg-name
  virtual_network_name = azurerm_virtual_network.dkart-vnet.name
  address_prefixes     = var.cidr-for-public-subnet

}

resource "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  =  var.rg-name
  virtual_network_name = azurerm_virtual_network.dkart-vnet.name
  address_prefixes     = var.cidr-for-bastion-subnet

}

resource "azurerm_subnet" "firewall-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  =  var.rg-name
  virtual_network_name = azurerm_virtual_network.dkart-vnet.name
  address_prefixes     = var.cidr-for-firewall-subnet

}


resource "azurerm_route_table" "public-route-table" {
  name                          = "dkart-dev-public-route-table"
  location                      = azurerm_virtual_network.dkart-vnet.location
  resource_group_name           =  var.rg-name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "route2"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }


  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet_route_table_association" "rt-association" {
  subnet_id      = azurerm_subnet.public-subnet.id
  route_table_id = azurerm_route_table.public-route-table.id
}

resource "azurerm_public_ip" "firewall-public-ip" {
  name                = "testpip"
  location            = azurerm_virtual_network.dkart-vnet.location
  resource_group_name = var.rg-name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = "testfirewall"
  location            = azurerm_virtual_network.dkart-vnet.location
  resource_group_name = var.rg-name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.firewall-public-ip.id
  }
}

resource "azurerm_public_ip" "bastion-public-ip" {
  name                = "dkart-bastion-public-ip"
  location            = azurerm_virtual_network.dkart-vnet.location
  resource_group_name = var.rg-name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion-host" {
  name                = "dkart-bastion"
  location            = azurerm_virtual_network.dkart-vnet.location
  resource_group_name = var.rg-name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion-public-ip.id
  }
}
