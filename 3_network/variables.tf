variable "subscription_id" {
  default = "_add_here_"
}

variable "client_id" {
  default = "_add_here_"
}

variable "client_secret" {
  default = "_add_here_"
}

variable "tenant_id" {
  default = "_add_here_"
}

variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  default = "_add_here_"
}

variable "prefix" {
  default = "demo"
}

variable "appname" {
  default = "landingzone"
}

variable "location" {
  default = "koreacentral"
}

variable "tag" {
  default = "demo"
}

variable "env" {
  default = "test"
}

# check latest VM sizes: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview
variable "vmsize" {
  default = "Standard_D2s_v3"
}
