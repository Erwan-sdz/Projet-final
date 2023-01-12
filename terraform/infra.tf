# Une clef SSH par région
resource "openstack_compute_keypair_v2" "keypair_gra11" {
  provider   = openstack.ovh  # utilisation du provider openstack de ovh
  name       = "sshkey_${var.student_id}" # nom de la clef ssh utilisé
  public_key = file("~/.ssh/id_rsa.pub") # utilisation d'une clef publique existante
  region     = "GRA11" # région ou la ressource est créée 
}
resource "openstack_compute_keypair_v2" "keypair_sbg5" {
  provider   = openstack.ovh # utilisation du provider openstack de ovh
  name       = "sshkey_${var.student_id}" # nom de la clef ssh utilisé
  public_key = file("~/.ssh/id_rsa.pub") # utilisation d'une clef publique existante
  region     = "SBG5" # région ou la ressource est créée 
}

# Front instance à GRA11
resource "openstack_compute_instance_v2" "front" {
  name        = "front_${var.student_id}" # nom de l'instance
  provider    = openstack.ovh # utilisation du provider openstack de ovh
  image_name  = "Debian 11" # image utilisé pour l'instance
  flavor_name = "s1-2" # type d'instance utilisé
  region      = "GRA11" # région ou la ressource est créée 
  key_pair    = openstack_compute_keypair_v2.keypair_gra11.name # utilisation de la clef ssh créée précédemment
  network {
    name      = "Ext-Net" # nom du réseau utilisé
  }
  network {
    name        = ovh_cloud_project_network_private.network.name # nom du réseau privé utilisé
    fixed_ip_v4 = "192.168.${var.vlan_id}.254" # adresse ip fixe
  }
  depends_on    = [ovh_cloud_project_network_private_subnet.subnet_gra11] # dépendance avec une autre ressource
}

# Déclaration de la resource de type openstack_compute_instance_v2 pour les backends en région GRA11
resource "openstack_compute_instance_v2" "gra_backends" {
  count       = var.gra_backends  # nombre d'instances à créer
  name        = "backend_${var.student_id}_gra_${count.index+1}" # nom des instances créées 
  provider    = openstack.ovh # utilisation de l'API OVH pour openstack
  image_name  = "Debian 11"  # utilisation de l'image Debian 11 pour les instances
  flavor_name = "s1-2"   # utilisation du type d'instance s1-2
  region      = "GRA11"  # région où les instances seront créées
  key_pair    = openstack_compute_keypair_v2.keypair_gra11.name # utilisation de la paire de clés keypair_gra11
  network {
    name      = "Ext-Net"  # utilisation du réseau Ext-Net pour les instances
  }
  network {
    name        = ovh_cloud_project_network_private.network.name # utilisation du réseau privé déclaré avec ovh_cloud_project_network_private
    fixed_ip_v4 = "192.168.${var.vlan_id}.${count.index + 1}"  # IP fixe pour les instances dans le réseau privé
  }
  depends_on    = [ovh_cloud_project_network_private_subnet.subnet_gra11] # dépendance sur la déclaration de la sous-réseau en région GRA11
}

# Déclaration de la resource de type openstack_compute_instance_v2 pour les backends en région SBG5
resource "openstack_compute_instance_v2" "sbg_backends" {
  count       = var.sbg_backends  # nombre d'instances à créer
  name        = "backend_${var.student_id}_sbg_${count.index+1}" # nom des instances créées
  provider    = openstack.ovh # utilisation de l'API OVH pour openstack
  image_name  = "Debian 11" # utilisation de l'image Debian 11 pour les instances
  flavor_name = "s1-2" # utilisation du type d'instance s1-2
  region      = "SBG5"  # région où les instances seront créées
  key_pair    = openstack_compute_keypair_v2.keypair_sbg5.name # utilisation de la paire de clés keypair_sbg5
  network {
    name      = "Ext-Net" # utilisation du réseau Ext-Net pour les instances
  }
  network {
    name        = ovh_cloud_project_network_private.network.name # utilisation du réseau privé déclaré avec ovh_cloud_project_network_private
    fixed_ip_v4 = "192.168.${var.vlan_id}.${count.index + 101}"  # IP fixe pour les instances dans le réseau privé en prenant en compte l'index
  }
  depends_on    = [ovh_cloud_project_network_private_subnet.subnet_sbg5] # dépendance sur la déclaration de la sous-réseau en région SBG5
}

# Déclaration de la resource de type local_file pour l'inventaire des instances
resource "local_file" "inventory" {
  filename = "../ansible/inventory.yml" # nom et chemin du fichier inventaire
  content  = templatefile("inventory.tmpl", # utilisation d'un template pour le contenu du fichier
    {
      sbg_backends = [for k, p in openstack_compute_instance_v2.sbg_backends: p.access_ip_v4], # adresses IP des instances backends en région SBG5
      gra_backends = [for k, p in openstack_compute_instance_v2.gra_backends: p.access_ip_v4], # adresses IP des instances backends en région GRA11
      front = openstack_compute_instance_v2.front.access_ip_v4, # adresse IP de l'instance front
    }
  )
}

# Déclaration de la resource de type ovh_cloud_project_network_private pour le Vrack réseau 
resource "ovh_cloud_project_network_private" "network" {
    service_name = var.service_name # nom du service
    name         = "private_network_${var.student_id}" # nom du réseau privé
    regions      = ["GRA11", "SBG5"] # régions disponibles
    provider     = ovh.ovh # fournisseur utilisé
    vlan_id      = var.vlan_id # ID de VLAN
}

# Vrack Subnet déclaration de la resource de type ovh_cloud_project_network_private_subnet pour la sous-réseau GRA11
resource "ovh_cloud_project_network_private_subnet" "subnet_gra11" {
    service_name = var.service_name # nom du service
    network_id   = ovh_cloud_project_network_private.network.id # identifiant du réseau
    start        = var.vlan_dhcp_start # début de l'interval DHCP
    end          = var.vlan_dhcp_end # fin de l'interval DHCP
    network      = var.vlan_dhcp_network # réseau DHCP
    region       = "GRA11" # région
    provider     = ovh.ovh 
    no_gateway   = true # pas de gateway
}

# Vrack Subnet déclaration de la resource de type ovh_cloud_project_network_private_subnet pour la sous-réseau SBG5
resource "ovh_cloud_project_network_private_subnet" "subnet_sbg5" {
    service_name = var.service_name # nom du service
    network_id   = ovh_cloud_project_network_private.network.id # identifiant du réseau
    start        = var.vlan_dhcp_start # début de l'interval DHCP
    end          = var.vlan_dhcp_end # fin de l'interval DHCP
    network      = var.vlan_dhcp_network # réseau DHCP
    region       = "SBG5" # région
    provider     = ovh.ovh 
    no_gateway   = true # pas de gateway
}
}