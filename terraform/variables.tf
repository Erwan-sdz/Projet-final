# Variable pour stocker l'identifiant de l'étudiant
variable "student_id" {
  default = "eductive23"
  type    = string
}

# Variable pour stocker le nombre de backend GRA
variable "gra_backends" {
  default = 1
  type    = number
}

# Variable pour stocker le nombre de backend SBG
variable "sbg_backends" {
  default = 1
  type    = number
}

# Variable pour stocker l'identifiant VLAN
variable "vlan_id" {
  default = 23
  type    = number
}

# Variable pour stocker le nom du service
variable "service_name" {
  type    = string
}

# Variable pour stocker le début de l'intervalle DHCP pour le VLAN
variable "vlan_dhcp_start" {
  type    = string
  default = "192.168.23.100"
}

# Variable pour stocker la fin de l'intervalle DHCP pour le VLAN
variable "vlan_dhcp_end" {
  type    = string
  default = "192.168.23.200"
}

# Variable pour stocker le réseau DHCP pour le VLAN
variable "vlan_dhcp_network" {
  type    = string
  default = "192.168.23.0/24"
}

# Variable pour stocker l'adresse IP privée des backend GRA
variable "gra_private_ip" {
  type    = string
  default = "192.168.23.1"
}

# Variable pour stocker l'adresse IP privée des backend SBG
variable "sbg_private_ip" {
  type    = string
  default = "192.168.23.101"
}

# Variable pour stocker l'adresse IP privée du frontend
variable "front_private_ip" {
  type    = string
  default = "192.168.23.254"
}

# Variable pour stocker les informations d'identification OVH
variable "ovh" {
  type = map(string)
  default = {
    endpoint           = "ovh-eu"
    application_key    = ""
    application_secret = ""
    consumer_key       = ""
  }
}

# Variable pour stocker les informations sur le produit
variable "product" {
  type = map(string)
  default = {
    project_id = ""
    region     = "GRA"
    plan       = "essential"
    flavor     = "db1-4"
    version    = "8"
  }
}

# Variable pour stocker les informations d'accès
variable "access" {
  type = map(string)
  default = {
    ip  = "$(curl ifconfig.me)/32"
 }
}
