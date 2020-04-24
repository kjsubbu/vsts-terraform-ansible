terraform {
  required_version = ">= 0.12"

  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}

}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = "javademo"
  location = "eastus"

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_storage_account" "stor" {
  name                     = "${var.dns_name}stor"
  location                 = "${azurerm_resource_group.rg.location}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.dns_name}avset"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "lbpip" {
  name                         = "${var.lb_ip_dns_name}-ip"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Static"
  domain_name_label            = "${var.lb_ip_dns_name}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.rg_prefix}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix}"
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "${var.rg_prefix}lb"
  location            = "${azurerm_resource_group.rg.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "SSH-VM-${count.index}"
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface" "nic" {
  name                = "nic${count.index}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = 2

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation           = "Dynamic"
    
  }
}

resource "azurerm_network_interface_nat_rule_association" "terrademo" {
  network_interface_id  = azurerm_network_interface.nic[count.index].id
  ip_configuration_name = "ipconfig${count.index}"
  nat_rule_id           = azurerm_lb_nat_rule.tcp[count.index].id
  count                 = 2


}

resource "azurerm_network_interface_backend_address_pool_association" "terrademo" {
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "ipconfig${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  count                   = 2
}
# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "vm${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  count                 = 2
  vm_size               = "Standard_D1"

  storage_os_disk {
    name          = "osdisk${count.index}"
    create_option = "FromImage"
  }

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
    admin_password = "Passwword1234"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdEXt5wSO1sxsq8Njir5lWZuDHhELv+5eEN/ISDi198ATcCc38eGwBUYwoHyXij7SB4Y6yn/qSmBbgyK6Yvu5wG+BIJpQSm8t4sL9ob4yirVl9FE1SeEIy79/fVUQzpS89Ct+EDq99pH0fw5Ve4JwaVjoKRACmOQq2naUgoaSDbk29fSgwudvJjLvsiaYF9wLpkCWYZK0QjXRd/4OnpwSGlP4sBd/zBRWYe0C88FdP6alttI3BTU3ZXKL5smLC+hcivIlPnkFMwEVW/+foKuL58nHoK7aBRBxLpLmNYLtRL9gzGNjGDzjO/Fm8SebSkFDEB8XWJyGh3iT5tGk5+Ktg4N1AlhoJnZXVPDfBxiBIfZqZ1MbFlLMDwAtb0XAkMZkO8LrgC/fZ9bXf2lhEeaAz8Vybh2JCvn0ZYMXtDm+U8rZ/TUcApw2W9BxvWNXWG2C3Uhj54dkliy6LExQUSu8go6eVzy8wyHhwk8fgfNop8MsglOieMA3JUOcKn3LJhPZk1qJ2E4BkHWqQYhd7dJXvICKxRy0sHNykSNORuYL+AeazUjv9WwCm4q1M526euWPPA+iFiiiHVkB/r9Y/fZCCd9/P1hdP065gTFhAZixwym1bvc9/r1+tefnEAL408hmN6bqIUbo/Ir0DdEYtAKs937F4yEIaHwCQHvk1YKEWZw== subbiah.k@kaats.in"
    }
  }

  tags = {
    environment = "Terraform Demo"
  }
}

output "vm_ip" {
  value = "${azurerm_public_ip.lbpip.fqdn}"
}

output "vm_dns" {
  value = "http://${azurerm_public_ip.lbpip.fqdn}"
}
