# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

#######################
# Environment Variables
#######################
# Use the command env | grep TF to see varibles

variable "region" {}
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "ssh_public_key" {}
variable "ssh_private_key_path" {}


#############################################
# User Supplied Variables in terraform.tfvars
#############################################

#OCI Paramaters
variable "vcn_name" {
  description = "user-friendly name for the vcn to be appended to the label_prefix"
  type        = string  
}

variable "label_prefix" {
  #If "none" resources will inherit vcn_name only.
  description = "a string that will be prepended to all resources"
  type        = string
 }

variable "vcn_dns_label" {
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet"
  type        = string  
}

variable "vcn_cidr" {  
  description = "cidr block of VCN"
  type = string  
}

# SDDC Network Paramaters 
variable "sddc_network_enabled" {
  description = "whether to deploy SDDC networks. If set to true, creates a SDDC networks."  
  type        = bool
}

variable "sddc_network_hardened" {
  description = "whether to apply hardening rules to SDDC networks"
  type        = bool
}

# SDDC Cluster Paramaters 
variable "sddc_enabled" {
  description = "whether to deploy SDDC Cluster. If set to true, creates a SDDC Cluster."  
  type        = bool
}

variable "sddc_display_name" {
  description = "AName applied to SDD cluster"
  type        = string
  default     = "none"
}

variable "esxi_hosts_count" {
  description = "Number of ESXi host deployrd to support DR workloads"
  type        = number
  default     = 3
}

variable "vmware_software_version" {
  description = "vSphere version to be deployed"
  type        = string
}

variable "initial_sku" {
  description = "Contract Length"
  type        = string
}

variable "is_hcx_enabled" {
  description = "whether to deploy SDDC Cluster. If set to true, creates a SDDC Cluster."
  type        = bool
}

variable "workload_network_cidr" {
  description = "CIDR block of SDDC workloads"
  type = string
}

variable "freeform_tags" {
  description = "simple key-value pairs to tag the resources created using freeform tags."
  type        = map(any)
  default = {}
}


variable "netnum" {
  description = "zero-based index of the subnet when the network is masked with the newbit. use as netnum parameter for cidrsubnet function"
  default = {
    bastion = 1
    internal = 2
  }
  type = map
}

variable "newbits" {
  description = "new mask for the subnet within the virtual network. use as newbits parameter for cidrsubnet function"
  default = {
    internal = 4
    bastion = 4
  }
  type = map
}

variable "lockdown_default_seclist" {
  description = "whether to remove all default security rules from the VCN Default Security List"
  default     = true
  type        = bool
}

#######################################################################################################################
# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
#######################################################################################################################

#############################
# Internet Gateway Paramaters 
#############################
variable "create_internet_gateway" {
  description = "whether to create the internet gateway in the vcn. If set to true, creates an Internet Gateway."
  default     = true
  type        = bool
}

locals {
  internet_gateway_route_rules = [ # this is a local that can be used to pass routing information to vcn module
  /*
    {
      destination       = "192.168.0.0/16" # Route Rule Destination CIDR
      destination_type  = "CIDR_BLOCK"     # only CIDR_BLOCK is supported at the moment
      network_entity_id = "drg"            # for nat_gateway_route_rules input variable, you can use special strings "drg", "nat_gateway" or pass a valid OCID using string or any Named Values
      description       = "Terraformed - User added Routing Rule: To drg created by this module. drg_id is automatically retrieved with keyword drg"
    },
    {
      destination       = "172.16.0.0/16"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = module.vcn.drg_id
      description       = "Terraformed - User added Routing Rule: To drg with drg_id directly passed by user. Useful for gateways created outside of vcn module"
    },
    {
      destination       = "203.0.113.0/24" # rfc5737 (TEST-NET-3)
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "nat_gateway"
      description       = "Terraformed - User added Routing Rule: rfc5737 (TEST-NET-3) To NAT Gateway created by this module. nat_gateway_id is automatically retrieved with keyword nat_gateway"
    },
    {
      destination       = "192.168.1.0/24"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_local_peering_gateway.lpg.id
      description       = "Terraformed - User added Routing Rule: To lpg with lpg_id directly passed by user. Useful for gateways created outside of vcn module"
    }
  */
  ]
}

#############################
# NAT Gateway Paramaters 
#############################
variable "create_nat_gateway" {
  description = "whether to create a nat gateway in the vcn. If set to true, creates a nat gateway."
  default     = true
  type        = bool
}


locals {
  nat_gateway_route_rules = [ # this is a local that can be used to pass routing information to vcn module for either route tables - https://github.com/oracle-terraform-modules/terraform-oci-vcn
  /*
    {
      destination       = "0.0.0.0.0/0" # Route Rule Destination CIDR
      destination_type  = "CIDR_BLOCK"     # only CIDR_BLOCK is supported at the moment
      network_entity_id = "drg"            # for nat_gateway_route_rules input variable, you can use special strings "drg", "nat_gateway" or pass a valid OCID using string or any Named Values
      description       = "NAT Gateway traffic"
    },
    {
      destination       = "172.16.0.0/16"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = module.vcn.drg_id
      description       = "Terraformed - User added Routing Rule: To drg with drg_id directly passed by user. Useful for gateways created outside of vcn module"
    },
    {
      destination       = "203.0.113.0/24" # rfc5737 (TEST-NET-3)
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "nat_gateway"
      description       = "Terraformed - User added Routing Rule: rfc5737 (TEST-NET-3) To NAT Gateway created by this module. nat_gateway_id is automatically retrieved with keyword nat_gateway"
    },
    {
      destination       = "192.168.1.0/24"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_local_peering_gateway.lpg.id
      description       = "Terraformed - User added Routing Rule: To lpg with lpg_id directly passed by user. Useful for gateways created outside of vcn module"
    }
  */
  ]
}

###############################
# Additional Gateway Paramaters 
###############################
variable "create_service_gateway" {
  description = "whether to create a service gateway. If set to true, creates a service gateway."
  default     = true
  type        = bool
}

variable "create_drg" {
  description = "whether to create Dynamic Routing Gateway. If set to true, creates a Dynamic Routing Gateway and attach it to the vcn."
  type        = bool
  default     = false
}

variable "drg_display_name" {
  description = "(Updatable) Name of Dynamic Routing Gateway. Does not have to be unique."
  type        = string
  default     = "drg"
}
 
variable "jumphost_image" {
    type = map
    default = {
        // See https://docs.cloud.oracle.com/iaas/images/
        // Oracle-provided image "Windows-Server-2019-Standard-Edition-VM-E3-2021.02.13-0"
        ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaatubanodym4uv3x2qaoq7elnntrajyurn4nqo5s5webg7aodjqmia"
        ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaakkrj6jz47d5cqxbo2bw33n5dheb3wroueferq65xhu5iq67a27sq"
        ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaggyipco74ftkg4m362iyyuqiskmoo7r5r4trqmkz2j7l2afbttya"
        ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaab7gvp5xiazonut7pgjjtfl7dmohktrok6gzv6pve5onvhhdnnoq"
        ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaap4z3hjhdqbgkihep3etek7be5dlobks7idxqdvybs3gk2rbesfiq"
        ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaasmospcmeh7fc75u3cxqgkkxpdif3zeoilmhgpm6egf5g45nrsrlq"
        ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaawtl7w3wlulegf5tt23vyjucoi6idulyramc3hgvpe3vwcjwk6oia"
        ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa7ex4dl67tvjffrzsa2qxiizbbkjnf3p4vrajxzjz2t2dhu4ktnva"
        ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaavvpgku4e6mrmgliwrjxwaih6uvygfycauzlg4iowo5r2vrs3yhda"
        ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaacv57zt6izl3ug55uxopygn2eakojptnypqgv5booxoq6vdhuusra"
        eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa55cblvc7jf7rgsvo5qrh5t6lhmb3ykgd34ym6pejq5oqgni7obiq"
        eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaavhfoaoxpognwoerpw2azcrtekywgzugmnt4lqmi2oq5ltdqal74q"
        eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaankjviwg7o4uyrbqsfklkell2atdnzzinwxryowoml5nbtthcspoq"
        me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaafk7azqkexrp52tcsajt4ebkivlb7x2im3rcysd42nyukfxwdouda"
        me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaq2e4tbqybnlapllmyhdu7kno4tn3xj3er3hurop4ws6ro2ppmmea"
        sa-santiago-1 = "ocid1.image.oc1.sa-santiago-1.aaaaaaaakcf2xshg7sq5m3ijtsiuqftqj4znry32a4jj5lsfhzpawzm5j37a"
        sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasjjcbj5flamve6z232crf4t3vwhdw6gsgogvzijy7umcyjfe4blq"
        uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaajass3zvseyizubhndrv2tgdib4ijzxxbbpst5gg5qvq2ajhcd52a"
        uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaaxuu4lblgswxrio6lnel3fi4l3nbwmorl2olcwo7ytfxdia7r7n3q"
        us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaalihxttg4gcn5gakhgxgkmlqbh5rtpulhv47ftaydsrh2ilu4eeya"
        us-gov-ashburn-1 = "ocid1.image.oc3.us-gov-ashburn-1.aaaaaaaafs5lnbimarqj6jjd22xscnqtdq3ir5qyjrikoalm2gtzgmu7ymmq"
        us-gov-chicago-1 = "ocid1.image.oc3.us-gov-chicago-1.aaaaaaaalvgrqbihw62a3q7gepgbcinywvcczuehapdt7hzmuznrfvaoqzqa"
        us-gov-phoenix-1 = "ocid1.image.oc3.us-gov-phoenix-1.aaaaaaaafgyik7j25rqitrl73brj27kvhu67zrgsu7rbodj2wru5f2ylhdva"
        us-langley-1 = "ocid1.image.oc2.us-langley-1.aaaaaaaacitvtu3cw7xwbkmjsc4lrpxi2f6s2zuznyjev5baadhue6ejcglq"
        us-luke-1 = "ocid1.image.oc2.us-luke-1.aaaaaaaaxk5uazx7og7wbxjngoysv7cmmwwle4lamkeonvzaeairuuejo44a"
        us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaajuo2ofct2huvrdq272to7sd6kvk6e7gwv5snqxjyyihx2xodb7ga"
        us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaawkvjhfa7cwra7a6u7f5n6gktvqfhhh4a52d6eckod3pwwhbwehia"
    }
}