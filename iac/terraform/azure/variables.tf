variable "storage-account-name" {
  default = "vstsbuildterraform"
}

variable "container-name" {
  default = "terraform-state"
}

variable "rg_prefix" {
  description = "The shortened abbreviation to represent your resource group that will go on the front of some resources."
  default     = "rg"
}

variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make up the FQDN."
  default     = "terrademojavaiac"
}

variable "lb_ip_dns_name" {
  description = "DNS for Load Balancer IP"
  default     = "terrademojavaiac"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "eastus"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_D1"
  }

variable "ssh_key" {
  description = "ssh_key"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdEXt5wSO1sxsq8Njir5lWZuDHhELv+5eEN/ISDi198ATcCc38eGwBUYwoHyXij7SB4Y6yn/qSmBbgyK6Yvu5wG+BIJpQSm8t4sL9ob4yirVl9FE1SeEIy79/fVUQzpS89Ct+EDq99pH0fw5Ve4JwaVjoKRACmOQq2naUgoaSDbk29fSgwudvJjLvsiaYF9wLpkCWYZK0QjXRd/4OnpwSGlP4sBd/zBRWYe0C88FdP6alttI3BTU3ZXKL5smLC+hcivIlPnkFMwEVW/+foKuL58nHoK7aBRBxLpLmNYLtRL9gzGNjGDzjO/Fm8SebSkFDEB8XWJyGh3iT5tGk5+Ktg4N1AlhoJnZXVPDfBxiBIfZqZ1MbFlLMDwAtb0XAkMZkO8LrgC/fZ9bXf2lhEeaAz8Vybh2JCvn0ZYMXtDm+U8rZ/TUcApw2W9BxvWNXWG2C3Uhj54dkliy6LExQUSu8go6eVzy8wyHhwk8fgfNop8MsglOieMA3JUOcKn3LJhPZk1qJ2E4BkHWqQYhd7dJXvICKxRy0sHNykSNORuYL+AeazUjv9WwCm4q1M526euWPPA+iFiiiHVkB/r9Y/fZCCd9/P1hdP065gTFhAZixwym1bvc9/r1+tefnEAL408hmN6bqIUbo/Ir0DdEYtAKs937F4yEIaHwCQHvk1YKEWZw== subbiah.k@kaats.in"
}
