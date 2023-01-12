# Définition des providers que l'on veut, avec une version éventuelle
terraform {
  required_version = ">= 0.14.0" # Version de terraform nécessaire
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0" # Version nécessaire pour le provider OpenStack
    }
    ovh = {
      source  = "ovh/ovh"
      version = ">= 0.13.0" # Version nécessaire pour le provider OVH
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3" # Version nécessaire pour le provider local
    }
  }
}

# Configure le fournisseur OpenStack hébergé par OVHcloud
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/"    # URL d'authentification pour OVHcloud
  domain_name = "default"                           # Nom de domaine - Toujours à "default" pour OVHcloud
  alias       = "ovh"                               # Un alias pour le provider OpenStack
}

provider "ovh" {
  alias    = "ovh" # Alias pour le provider OVH
  endpoint = "ovh-eu" # point d'extrémité de l'API OVH
}
