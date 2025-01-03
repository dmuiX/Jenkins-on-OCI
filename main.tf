### BASIC TERRAFORM AND OCI STUFF ###
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.21.0"
    }
  }
  cloud {
    organization = "dmuiX" #https://app.terraform.io/app/organizations
    workspaces {
      name = "jenkins-on-oci" #https://app.terraform.io/app/organizations/dmuiX/workspaces
    }                         # NO VARIABLES ALLOWED HERE!
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  private_key  = var.private_key # best way: export TF_VAR_private_key=`openssl rsa -in ~/.oci/private.key -check` and no passphrase necessary!!
  fingerprint  = var.fingerprint
  region       = var.region
}

### IAM and IDENTITY ###

resource "oci_identity_compartment" "jenkins-on-oci_compartment" {
  # Required
  compartment_id = var.tenancy_ocid
  description    = "Compartment for jenkins-cluster-on-oci"
  name           = "jenkins-on-oci_compartment"
}

resource "oci_kms_vault" "jenkins-on-oci_vault" {
  compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
  display_name   = "jenkins-on-oci_vault"
  vault_type     = "DEFAULT" # No information what should stand here...
}

# This resource will destroy (potentially immediately) after null_resource.next

# resource "time_sleep" "wait_30_seconds" {
#     depends_on = [ oci_kms_vault.jenkins-on-oci_vault ]

#     create_duration = "30s"
# }

resource "oci_kms_key" "jenkins-on-oci_master-key" {
  compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
  display_name   = "jenkins-on-oci_master-key"
  key_shape {
    #Required
    algorithm = "AES"
    length    = 32
  }
  depends_on          = [oci_kms_vault.jenkins-on-oci_vault] # depends_on Necessary!!
  management_endpoint = oci_kms_vault.jenkins-on-oci_vault.management_endpoint
}

resource "oci_identity_user" "jenkins-on-oci_admin" {
  compartment_id = var.tenancy_ocid # tenancy necessary
  description    = "create jenkins-on-oci_admin user"
  name           = "jenkins-on-oci_admin"
  email          = var.email
}

resource "oci_identity_group" "jenkins-on-oci_admins" {
  compartment_id = var.tenancy_ocid # tenancy necessary
  description    = "create group jenkins-on-oci_admins"
  name           = "jenkins-on-oci_admins"
}

resource "oci_identity_user_group_membership" "admin_group_membership" {
  group_id   = oci_identity_group.jenkins-on-oci_admins.id
  user_id    = oci_identity_user.jenkins-on-oci_admin.id
  depends_on = [oci_identity_group.jenkins-on-oci_admins, oci_identity_user.jenkins-on-oci_admin]
}

resource "oci_identity_policy" "jenkins-on-oci_policies" {
  compartment_id = var.tenancy_ocid # tenancy necessary statements = ["Allow group jenkins-on-oci_admins to manage all-resources in compartment jenkins-on-oci_compartment"]
  description    = "policies to allow to manage every component necessary to make this cluster run"
  name           = "jenkins-on-oci_computing-policy"
  statements     = [
    "Allow service vcn to manage all-resources in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}",
    "Allow group ${oci_identity_group.jenkins-on-oci_admins.name} to manage all-resources in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}"
]
  # statements = [
  #     "Allow group ${oci_identity_group.jenkins-on-oci_admins.name} to manage compute-management-family in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}",
  #     "Allow group ${oci_identity_group.jenkins-on-oci_admins.name} to manage instance-family in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}",
  #     "Allow group ${oci_identity_group.jenkins-on-oci_admins.name} to manage volume-family in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}",
  #     "Allow group ${oci_identity_group.jenkins-on-oci_admins.name} to manage virtual-network-family in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}",
  #     "Allow service compute, blockstorage, compute_management to use key-family in compartment ${oci_identity_compartment.jenkins-on-oci_compartment.name}",
  # ]
  depends_on = [oci_kms_vault.jenkins-on-oci_vault, oci_identity_user.jenkins-on-oci_admin, oci_identity_group.jenkins-on-oci_admins]
}

# ### NETWORKING ###

resource "oci_core_vcn" "jenkins-on-oci_vcn" {
  compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
  cidr_blocks    = [var.public_subnet_cidr]
}

# ### PUBLIC SECTION ###

resource "oci_core_internet_gateway" "jenkins-on-oci_internet-gateway" {
  compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
  vcn_id         = oci_core_vcn.jenkins-on-oci_vcn.id
}

# # resource "oci_core_network_security_group" "jenkins-on-oci_nsg" {
# #     compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
# #     vcn_id = oci_core_vcn.jenkins-on-oci_vcn.id
# # }

# # resource "oci_core_network_security_group_security_rule" "jenkins-on-oci_nsg_security_rules" {

# # }

resource "oci_core_security_list" "jenkins-on-oci_public-subnet_security-list" {
  compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
  vcn_id         = oci_core_vcn.jenkins-on-oci_vcn.id
}

resource "oci_core_route_table" "jenkins-on-oci_public-subnet_route-table" {
  compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
  vcn_id         = oci_core_vcn.jenkins-on-oci_vcn.id
  route_rules {
    network_entity_id = oci_core_internet_gateway.jenkins-on-oci_internet-gateway.id
    description       = "Public Subnet Route Table"
    destination       = "0.0.0.0/24"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "jenkins-on-oci_public_subnet" {
  cidr_block        = var.public_subnet_cidr
  compartment_id    = oci_identity_compartment.jenkins-on-oci_compartment.id
  vcn_id            = oci_core_vcn.jenkins-on-oci_vcn.id
  security_list_ids = [oci_core_security_list.jenkins-on-oci_public-subnet_security-list.id]
  route_table_id    = oci_core_route_table.jenkins-on-oci_public-subnet_route-table.id
  # prohibit_public_ip_on_vnic = 
  # display_name = var.subnet_display_name
  # dns_label = var.subnet_dns_label

  # omit availability_domain => Regional Subnet

  #uses default when not specified:
  #route_table_id = oci_core_route_table.test_route_table.id
  #security_list_ids = var.subnet_security_list_ids
}

# resource "oci_load_balancer_load_balancer" "jenkins-on-oci_load_balancer" {
#     compartment_id = oci_identity_compartment.jenkins-on-oci_compartment.id
#     subnet_ids = [ var.public_subnet_cidr ]
#     display_name = var.loadbalancer
#     # is_private = true THEN I need a VPN!
#     shape = var.loadbalancer_shape
#     depends_on = [ oci_identity_policy.jenkins-on-oci_policies ]
# }

# ### COMPUTING INSTANCES ###

resource "oci_core_instance" "jenkins_instance" {
  availability_domain = var.availability_domain
  compartment_id      = oci_identity_compartment.jenkins-on-oci_compartment.id
  shape               = var.arm_shape
  metadata = {
    "ssh_authorized_key" = var.ssh_public_key
  }
  shape_config {
    memory_in_gbs = var.memory_in_gbs
    ocpus         = var.ocpus
  }
  create_vnic_details {
    # hostname_label = var.jenkins_fqdn
    display_name = var.jenkins_fqdn
    # assign_private_dns_record = var.jenkins_fqdn
    # private_ip = var.jenkins_ip
    subnet_id = oci_core_subnet.jenkins-on-oci_public_subnet.id
  }
  source_details {
    source_type             = "image"
    kms_key_id              = oci_kms_key.jenkins-on-oci_master-key.id
    source_id               = var.platform_image
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }
}
