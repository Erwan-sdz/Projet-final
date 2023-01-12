# Projet Déploiement et Configuration d'une infrastructure

## Description du projet et objectif

Le projet vise à créer une infrastructure complète en utilisant les outils Terraform et Ansible. L'objectif final étant de mettre en place une plateforme Wordpress en haute disponibilité. Cette plateforme devra être capable de gérer des charges importantes et de résister aux éventuelles pannes.

Pour atteindre cet objectif, il sera nécessaire de concevoir une architecture résiliente qui prévoit des redondances et des mesures de reprise d'activité en cas de panne. Il sera également important de se concentrer sur l'évolutivité de l'infrastructure pour pouvoir évoluer facilement avec les besoins en ressources.

En utilisant Terraform pour le déploiement, il sera possible de générer automatiquement l'infrastructure nécessaire pour mettre en place cette plateforme Wordpress haute disponibilité. Ansible sera utilisé pour configurer cette infrastructure automatiquement, afin d'éviter les erreurs humaines et de garantir une configuration standardisée.

En utilisant ces deux outils, il sera possible de mettre en place une infrastructure automatisée, évolutive et résiliente, garantissant ainsi la disponibilité continue des services proposés par la plateforme Wordpress.


# Pré-requis pour les différentes instances 

## Paramètres communs aux instances compute

- Ces paramètres s'appliquent à toutes les instances, à l'exception de la base de données.
- Les instances doivent être de type `s1-2` (flavor).
- Les instances doivent utiliser le système d'exploitation `Debian 11`.
- Les instances doivent être connectées à un réseau privé avec une adresse IP définie sur `192.168.23.0/24`.
- Les instances doivent avoir une interface réseau sur un réseau public.
- Les instances doivent avoir une interface réseau sur un Vrack.

## Paramètres Vrack

- Le VLAN utilisé pour les instances doit être le numéro `23`.
- Les régions supportées pour les instances sont `GRA11` et `SBG5`.

## Paramètres DB

- Le plan choisi pour la base de données est `essential`.
- Le type de l'instance (flavor) choisi est `db1-4`.
- La version de la base de données utilisée est la `8`.
- La région choisie pour la base de données est `GRA`.

# Noms des instances

- L'instance Front aura pour nom `front_eductive23`.
- Les instances Backend auront les noms suivants : 
  - GRA : `backend_eductive23_gra_1`, `backend_eductive23_gra_2` …
  - SBG : `backend_eductive23_sbg_1`, `backend_eductive23_sbg_2` …
- L'instance DB aura pour nom `db_eductive23`


### Les étapes nécessaires

- Lancer la commande
- eductive23@master:~/project$ source ~/openrc.sh
- eductive23@master:~/project$ echo $OS_TENANT_ID
- 9957f50cea694f13b26cc064d04b2e95
- source ~/openrc.sh est une commande shell qui permet de charger les variables d'environnement contenues dans le fichier openrc.sh, les variables d'environnement présente dans le fichier permette une authentification avec OpenStack pour accéder à l'API cloud OVH.


# Plan d'exécution Terraform

Ensuite pour prévoire le déploiement de l'infrastructure il faut lancer la commande :
- eductive23@master:~/project$ terraform plan

Ce qui affiche le déploiement prévue par terraform en fonction des différents fichiers de configuration.

Le plan d'exécution décrit les actions qui seront effectuées sur les ressources lorsque la commande `terraform apply` sera utilisée. Il décrit trois ressources qui vont être créées : 
- Une ressource de type "local_file" nommée "inventory" qui va créer un fichier sur le système local.
  # local_file.inventory will be created
      + filename             = "../project/inventory.yml"

- Une ressource de type "openstack_compute_instance_v2" nommée "front" qui va créer une instance OpenStack.
  # openstack_compute_instance_v2.front will be created

- Une ressource de type "openstack_compute_instance_v2" nommée "gra_backends" / "sbg_backends" qui va créer plusieurs instances OpenStack. 
  - openstack_compute_instance_v2.gra_backends[0] will be created
  - openstack_compute_instance_v2.gra_backends[1] will be created
  - openstack_compute_instance_v2.sbg_backends[0] will be created
  - openstack_compute_instance_v2.sbg_backends[1] will be created

- Terraform va créer deux clés de pair de calcul OpenStack nommées "keypair_gra11" et "keypair_sbg5" dans les régions "GRA11" et "SBG5".
  - openstack_compute_keypair_v2.keypair_gra11 will be created
  - openstack_compute_keypair_v2.keypair_sbg5 will be created

- Terraform va créer un network privée "network" et deux sous-réseaux privés "subnet_gra11" et "subnet_sbg5" respectivement dans les régions "GRA11" et "SBG5" . Ces ressources appartiennent à un projet OVH.
  - ovh_cloud_project_network_private.network will be created
  - ovh_cloud_project_network_private_subnet.subnet_gra11 will be created
  - ovh_cloud_project_network_private_subnet.subnet_sbg5 will be created

## Ansible 

Pour lancer l'installation du HAproxy, montage NFS, Nginx, Docker sur la partie front ansi que installer la page web sur les serveurs backends on "joue" le playbook avec cette commande `ansible-playbook deplay-playbook.yml -i inventory.yml`

Il va prendre en compte le fichier inventory.yml qui est créé à l'aide du fichier inventory.tmpl (info host).

Avec le haproxy et le système de load-balencer on peut voir que les instances équilibres les charges en actualisant la page web front qui est la seul qui a la possibilitès d'afficher la page index.

![Test Image 4](https://github.com/Erwan-sdz/Blog-IUT/blob/main/Capture%20d%E2%80%99%C3%A9cran%202023-01-12%20100714.png)
![Test Image 4](https://github.com/Erwan-sdz/Blog-IUT/blob/main/Capture%20d%E2%80%99%C3%A9cran%202023-01-12%20100750.png)


## Exemple d'un ansible-playbook pour voir les configurations qu'il applique sur les différentes instances

Voici le résultat de la commande
 - eductive23@master:~/projet/ansible$ ansible-playbook deplay-playbook.yml -i inventory.yml --ssh-common-args='-o StrictHostKeyChecking=no'

```

PLAY [Install and configure a web page on backends] **************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Update and upgrade apt packages] ***************************************************************************************************************************************************************
[WARNING]: The value "True" (type bool) was converted to "'True'" (type string). If this does not look like what you expect, quote the entire value to ensure it does not change.
ok: [57.128.18.135]
ok: [51.68.90.216]

TASK [Ensure package nginx is installed] *************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Ensure service nginx is running] ***************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Configure Kitten Page] *************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Configure Nginx to listen on vrack] ************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

PLAY [install Docker] ********************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Install apt-transport-https] *******************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Add signing key] *******************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Add repository into sources list] **************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Install Docker] ********************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

PLAY [Install and configure haproxy on front] ********************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
ok: [57.128.18.175]

TASK [Ensure package haproxy is installed] ***********************************************************************************************************************************************************
ok: [57.128.18.175]

TASK [Ensure service haproxy is running] *************************************************************************************************************************************************************
ok: [57.128.18.175]

TASK [Configure haproxy] *****************************************************************************************************************************************************************************
ok: [57.128.18.175]

PLAY [NFS Server on front] ***************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
ok: [57.128.18.175]

TASK [Install NFS] ***********************************************************************************************************************************************************************************
ok: [57.128.18.175]

TASK [NFS share directory] ***************************************************************************************************************************************************************************
ok: [57.128.18.175]

TASK [Add NFS share to exports] **********************************************************************************************************************************************************************
ok: [57.128.18.175]

PLAY [NFS Client on backends] ************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

TASK [Install NFS client] ****************************************************************************************************************************************************************************
ok: [51.68.90.216]
ok: [57.128.18.135]

PLAY RECAP *******************************************************************************************************************************************************************************************
51.68.90.216               : ok=12   changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
57.128.18.135              : ok=12   changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
57.128.18.175              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```


## Exemple d'un terraform show pour voir les instances et réseaux 
eductive23@master:~/projet/terraform$ terraform show

```

# local_file.inventory:
resource "local_file" "inventory" {
    content              = <<-EOT
        ---
        front:
          hosts:
            57.128.18.175:
              ansible_user: debian
              ansible_become: True
        backends:
          hosts:
            51.68.90.216:
              ansible_user: debian
              ansible_become: True
            57.128.18.135:
              ansible_user: debian
              ansible_become: True

    EOT
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "../ansible/inventory.yml"
    id                   = "1b35a0a82ee5346701c10168657addaa8a539329"
}

# openstack_compute_instance_v2.front:
resource "openstack_compute_instance_v2" "front" {
    access_ip_v4        = "57.128.18.175"
    access_ip_v6        = "[2001:41d0:304:300::1619]"
    all_metadata        = {}
    all_tags            = []
    availability_zone   = "nova"
    flavor_id           = "fa05492b-f252-4287-bf26-8bfa62933c6a"
    flavor_name         = "s1-2"
    force_delete        = false
    id                  = "758a84a1-f3b6-46c2-9c18-da62dcbdf6ef"
    image_id            = "a32aaf69-72d8-4b98-9e6a-67929fa1b9cb"
    image_name          = "Debian 11"
    key_pair            = "sshkey_eductive23"
    name                = "front_eductive23"
    power_state         = "active"
    region              = "GRA11"
    security_groups     = [
        "default",
    ]
    stop_before_destroy = false
    tags                = []

    network {
        access_network = false
        fixed_ip_v4    = "57.128.18.175"
        fixed_ip_v6    = "[2001:41d0:304:300::1619]"
        mac            = "fa:16:3e:51:8c:b8"
        name           = "Ext-Net"
        uuid           = "bcf59eb2-9d83-41cc-b4f5-0435ed594833"
    }
    network {
        access_network = false
        fixed_ip_v4    = "192.168.23.254"
        mac            = "fa:16:3e:1a:20:81"
        name           = "private_network_eductive23"
        uuid           = "918c622d-d25f-4ba0-99a5-2a9225ff139c"
    }
}

# openstack_compute_instance_v2.gra_backends[0]:
resource "openstack_compute_instance_v2" "gra_backends" {
    access_ip_v4        = "57.128.18.135"
    access_ip_v6        = "[2001:41d0:304:300::1613]"
    all_metadata        = {}
    all_tags            = []
    availability_zone   = "nova"
    flavor_id           = "fa05492b-f252-4287-bf26-8bfa62933c6a"
    flavor_name         = "s1-2"
    force_delete        = false
    id                  = "6a21971a-58dc-4f6a-a7cb-3a06cef3f86e"
    image_id            = "a32aaf69-72d8-4b98-9e6a-67929fa1b9cb"
    image_name          = "Debian 11"
    key_pair            = "sshkey_eductive23"
    name                = "backend_eductive23_gra_1"
    power_state         = "active"
    region              = "GRA11"
    security_groups     = [
        "default",
    ]
    stop_before_destroy = false
    tags                = []

    network {
        access_network = false
        fixed_ip_v4    = "57.128.18.135"
        fixed_ip_v6    = "[2001:41d0:304:300::1613]"
        mac            = "fa:16:3e:77:72:e2"
        name           = "Ext-Net"
        uuid           = "bcf59eb2-9d83-41cc-b4f5-0435ed594833"
    }
    network {
        access_network = false
        fixed_ip_v4    = "192.168.23.1"
        mac            = "fa:16:3e:9c:5a:04"
        name           = "private_network_eductive23"
        uuid           = "918c622d-d25f-4ba0-99a5-2a9225ff139c"
    }
}

# openstack_compute_instance_v2.sbg_backends[0]:
resource "openstack_compute_instance_v2" "sbg_backends" {
    access_ip_v4        = "51.68.90.216"
    access_ip_v6        = "[2001:41d0:404:100::18ca]"
    all_metadata        = {}
    all_tags            = []
    availability_zone   = "nova"
    flavor_id           = "ce07016c-95df-4085-bb5a-565caffc2063"
    flavor_name         = "s1-2"
    force_delete        = false
    id                  = "8b48f3f6-02ce-4d33-b7e7-fdcae185869f"
    image_id            = "b6b0399c-b631-48ea-9b62-629579cf91f0"
    image_name          = "Debian 11"
    key_pair            = "sshkey_eductive23"
    name                = "backend_eductive23_sbg_1"
    power_state         = "active"
    region              = "SBG5"
    security_groups     = [
        "default",
    ]
    stop_before_destroy = false
    tags                = []

    network {
        access_network = false
        fixed_ip_v4    = "51.68.90.216"
        fixed_ip_v6    = "[2001:41d0:404:100::18ca]"
        mac            = "fa:16:3e:2f:e5:28"
        name           = "Ext-Net"
        uuid           = "581fad02-158d-4dc6-81f0-c1ec2794bbec"
    }
    network {
        access_network = false
        fixed_ip_v4    = "192.168.23.101"
        mac            = "fa:16:3e:3f:fc:f8"
        name           = "private_network_eductive23"
        uuid           = "e305875c-de9a-4b74-9cd5-3a4a259cd476"
    }
}

# openstack_compute_keypair_v2.keypair_gra11:
resource "openstack_compute_keypair_v2" "keypair_gra11" {
    fingerprint = "05:46:1e:b6:7e:7f:d0:bf:6b:a2:1f:24:44:68:1d:50"
    id          = "sshkey_eductive23"
    name        = "sshkey_eductive23"
    public_key  = <<-EOT
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPVsHNqbBB19m3ofxLGncuTZzXGIZtwQTfY4RfWHChxHhXZSA2d9XlbC1hXTbBUQ0q9yfBonb/J2HwLD+ljVf0W2vIjbrV+HOG7xaOajDsLLQTzdQzSdum/iB570VLrKcTvjUJaQ/JHSWWvgABnVKp9RlZprcKsuR50RM37lMgnBwzWXZpBHnfKo7/Y6waOEEU3uBBJuFwQXANGP5a94v54LMK557Ij1qInfJwx+U681Q1CUxlRUHtKR0uVavtzc/CNrE1B8aL+9cQuJkIt0BFi0ffHi6GKCe39kunn78TLD+GT7oFc+fMH/at/NIMNtqVWay7Cw67iBhX2fNWFthigckQxXAeB/m9KnM9LtTtyRj4ZOB/qoSxNJQfmaEDUDdz3LzQfOUFD1Zy4bpKOyT9o+BfZOCJ/84+E+exVX3ACMWPSVWl77Q9Oo1IUQMPP11X5DYocntwCgWU4PiUitLtiyAe9iyAcYGflS9JthRM6kD0jXDkYqOrlN1iNIie8058WaFCvSpj9KjsHSPUXociGgFBUgMtgP8+6ojINE6Xz3efSstyDvIq8ZtcHVeeueFbzlnTE5P6U6JBqc16HBA2p76NokX74wpBtnjju9G+Ep5wuTNYunABPG8+V1z8KQQ8tj/g/30hOo6YDJ8FU/PVTVqKXF2VT63eOMaUEvP5RQ== eductive23@master.thisistheway.ovh
    EOT
    region      = "GRA11"
}

# openstack_compute_keypair_v2.keypair_sbg5:
resource "openstack_compute_keypair_v2" "keypair_sbg5" {
    fingerprint = "05:46:1e:b6:7e:7f:d0:bf:6b:a2:1f:24:44:68:1d:50"
    id          = "sshkey_eductive23"
    name        = "sshkey_eductive23"
    public_key  = <<-EOT
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPVsHNqbBB19m3ofxLGncuTZzXGIZtwQTfY4RfWHChxHhXZSA2d9XlbC1hXTbBUQ0q9yfBonb/J2HwLD+ljVf0W2vIjbrV+HOG7xaOajDsLLQTzdQzSdum/iB570VLrKcTvjUJaQ/JHSWWvgABnVKp9RlZprcKsuR50RM37lMgnBwzWXZpBHnfKo7/Y6waOEEU3uBBJuFwQXANGP5a94v54LMK557Ij1qInfJwx+U681Q1CUxlRUHtKR0uVavtzc/CNrE1B8aL+9cQuJkIt0BFi0ffHi6GKCe39kunn78TLD+GT7oFc+fMH/at/NIMNtqVWay7Cw67iBhX2fNWFthigckQxXAeB/m9KnM9LtTtyRj4ZOB/qoSxNJQfmaEDUDdz3LzQfOUFD1Zy4bpKOyT9o+BfZOCJ/84+E+exVX3ACMWPSVWl77Q9Oo1IUQMPP11X5DYocntwCgWU4PiUitLtiyAe9iyAcYGflS9JthRM6kD0jXDkYqOrlN1iNIie8058WaFCvSpj9KjsHSPUXociGgFBUgMtgP8+6ojINE6Xz3efSstyDvIq8ZtcHVeeueFbzlnTE5P6U6JBqc16HBA2p76NokX74wpBtnjju9G+Ep5wuTNYunABPG8+V1z8KQQ8tj/g/30hOo6YDJ8FU/PVTVqKXF2VT63eOMaUEvP5RQ== eductive23@master.thisistheway.ovh
    EOT
    region      = "SBG5"
}

# ovh_cloud_project_network_private.network:
resource "ovh_cloud_project_network_private" "network" {
    id                 = "pn-1089024_23"
    name               = "private_network_eductive23"
    regions            = [
        "GRA11",
        "SBG5",
    ]
    regions_attributes = [
        {
            openstackid = "918c622d-d25f-4ba0-99a5-2a9225ff139c"
            region      = "GRA11"
            status      = "ACTIVE"
        },
        {
            openstackid = "e305875c-de9a-4b74-9cd5-3a4a259cd476"
            region      = "SBG5"
            status      = "ACTIVE"
        },
    ]
    regions_status     = [
        {
            region = "SBG5"
            status = "ACTIVE"
        },
    ]
    service_name       = "9957f50cea694f13b26cc064d04b2e95"
    status             = "ACTIVE"
    type               = "private"
    vlan_id            = 23
}

# ovh_cloud_project_network_private_subnet.subnet_gra11:
resource "ovh_cloud_project_network_private_subnet" "subnet_gra11" {
    cidr         = "192.168.23.0/24"
    dhcp         = false
    end          = "192.168.23.200"
    id           = "e6440f5c-bb35-4f60-af08-a32253772bf3"
    ip_pools     = [
        {
            dhcp    = false
            end     = "192.168.23.200"
            network = "192.168.23.0/24"
            region  = "GRA11"
            start   = "192.168.23.100"
        },
    ]
    network      = "192.168.23.0/24"
    network_id   = "pn-1089024_23"
    no_gateway   = true
    region       = "GRA11"
    service_name = "9957f50cea694f13b26cc064d04b2e95"
    start        = "192.168.23.100"
}

# ovh_cloud_project_network_private_subnet.subnet_sbg5:
resource "ovh_cloud_project_network_private_subnet" "subnet_sbg5" {
    cidr         = "192.168.23.0/24"
    dhcp         = false
    end          = "192.168.23.200"
    id           = "a39c54ed-ca9e-4579-82b6-5ea3d85f1988"
    ip_pools     = [
        {
            dhcp    = false
            end     = "192.168.23.200"
            network = "192.168.23.0/24"
            region  = "SBG5"
            start   = "192.168.23.100"
        },
    ]
    network      = "192.168.23.0/24"
    network_id   = "pn-1089024_23"
    no_gateway   = true
    region       = "SBG5"
    service_name = "9957f50cea694f13b26cc064d04b2e95"
    start        = "192.168.23.100"
}

```
