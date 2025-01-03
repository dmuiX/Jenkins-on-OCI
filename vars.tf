variable "tenancy_ocid" {
  description = "Oracle Cloud tenancy OCID"
  type        = string
}

variable "user_ocid" {
  description = "Oracle Cloud user OCID"
  type        = string
}

variable "fingerprint" {
  description = "SSH key fingerprint"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Oracle Cloud region"
  type        = string
}


variable "compartment_name" {
  description = "Oracle Cloud Compartment Name"
  type        = string
}

variable "email" {
  description = "email"
  type        = string
}

variable "private_key" {
  description = "oci private key"
  type        = string
  sensitive   = true
}

# variable "private_key_passphrase" {
#   description = "oci private key passphrase"
#   type        = string
#   sensitive   = true
# }

variable "arm_shape" {
  description = "Oracle Cloud Arm Compute Shape"
  type        = string
}

variable "amd_shape" {
  description = "Oracle Cloud Amd Compute Shape"
  type        = string
}

variable "platform_image" {
  description = "Oracle Cloud Platform Image"
  type        = string
}

variable "ssh_public_key" {
  description = "ssh public key"
  type        = string
}

variable "memory_in_gbs" {
  description = "instance ram"
  type        = number
}

variable "ocpus" {
  description = "instance cpus"
  type        = number
}

variable "boot_volume_size_in_gbs" {
  description = "boot volume size"
  type        = number
}

variable "availability_domain" {
  description = "Oracle Cloud Availability Domain Control Node 1"
  type        = string
}

variable "loadbalancer" {
  description = "Cluster loadbalancer"
  type        = string
}

variable "loadbalancer_shape" {
  description = "Cluster loadbalancer shape"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Cluster public subnet ip"
  type        = string
}

variable "jenkins_fqdn" {
  description = "Jenkins FQDN"
  type        = string
}

variable "jenkins_ip" {
  description = "Jenkins IP"
  type        = string
}

# variable "private_subnet_cidr" {
#     description = "Cluster private subnet ip"
#     type = string
# }

# variable "bucket_name" {
#   type = string
# }

# variable "control_node_1_fqdn" {
#     type = string
# }

# variable "control_node_1_ip" {
#     type = string
# }

# variable "control_node_2_fqdn" {
#     type = string
# }

# variable "control_node_2_ip" {
#     type = string
# }

# variable "ttl" {
#   type = string
#   default = "60"
# }

# variable "type_A" {
#   type = string
#   default = "A"
# }

# variable "type_CNAME" {
#   type = string
#   default = "CNAME"
# }

# variable "worker_node_1_fqdn" {
#   type = string
# }

# # variable "worker_node_1_hostname" {
# #   type = string
# # }

# variable "worker_node_1_ip" {
#   type = string
# }

# variable "worker_node_2_fqdn" {
#   type = string
# }

# # variable "worker_node_2_hostname" {
# #   type = string
# # }

# variable "worker_node_2_ip" {
#   type = string
# }

# variable "wildcard_virtual-lab_fqdn" {
#   type = string
# }

# variable "zone_name" {
#   type = string
# }

# variable "cloudflare_api_token" {
#   type = string
# }

# variable "bucket_name" {
#   type = string
# }

# variable "bucket_policy" {
#   type = string
# }

# variable "iamrole" {
#   type = string
# }

# variable "dynamodb_table_name" {
#   type = string
# }

# variable "dynamodb_policy" {
#   type = string  
# }

# variable "key" {
#   type = string
# }
