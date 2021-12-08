// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      version = ">=4.41.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "oci" {
  region           = var.region
}

provider "oci" {
  alias            = "home"
}


module "vcn" { 
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.0.0"

  # general oci parameters
  region                       = var.region   
  compartment_id               = var.compartment_ocid
  label_prefix                 = var.label_prefix

  # vcn parameters
  create_internet_gateway      = var.create_internet_gateway
  create_nat_gateway           = var.create_nat_gateway
  create_service_gateway       = var.create_service_gateway
  create_drg                   = var.create_drg
  drg_display_name             = var.drg_display_name
  vcn_cidrs                    = [var.vcn_cidr]
  vcn_dns_label                = var.vcn_dns_label
  vcn_name                     = var.vcn_name
  lockdown_default_seclist     = var.lockdown_default_seclist

   # routing rules
  internet_gateway_route_rules = local.internet_gateway_route_rules # this module input shows how to pass routing information to the vcn module through  Variable Input. Can be initialized in a *.tfvars or *.auto.tfvars file
  nat_gateway_route_rules      = local.nat_gateway_route_rules    # this module input shows how to pass routing information to the vcn module through Local Values.

  freeform_tags                = var.freeform_tags
}

module "vcn_networks" {
  source = "./modules/vcn"

  vcn_id                       = module.vcn.vcn_id 
  vcn_cidr                     = var.vcn_cidr
  workload_network_cidr        = var.workload_network_cidr
  compartment_id               = var.compartment_ocid
  label_prefix                 = var.label_prefix
  netnum                       = var.netnum["internal"]
  newbits                      = var.newbits["internal"]
  route_table_id               = module.vcn.nat_route_id

  freeform_tags                = var.freeform_tags
}

module "bastion" {
  source  = "oracle-terraform-modules/bastion/oci"
  version = "3.0.0"
  tenancy_id                    = var.tenancy_ocid
  compartment_id                = var.compartment_ocid
  label_prefix                  = var.label_prefix
  ig_route_id                   = module.vcn.ig_route_id
  vcn_id                        = module.vcn.vcn_id
  netnum                        = var.netnum["bastion"]
  newbits                       = var.newbits["bastion"]
  ssh_public_key_path           = "~/.ssh/id_rsa.pub"
  upgrade_bastion               = false

  freeform_tags                 = var.freeform_tags

  providers = {
    oci.home = oci.home
  }
}

module "instance" {
  source = "oracle-terraform-modules/compute-instance/oci"
  version        = "2.2.0"
   # general oci parameters
  instance_count                = 1 # how many instances do you want?
  ad_number                     = 1 # AD number to provision instances. If null, instances are provisionned in a rolling manner starting with AD1
  compartment_ocid              = var.compartment_ocid
  subnet_ocids                  = [module.vcn_networks.internal_subnet_id]
  # compute instance parameters
  instance_display_name         = var.label_prefix == "none" ? "jumpbox" : "${var.label_prefix}-jumpbox"
  source_ocid                   = var.jumphost_image[var.region]
  instance_flex_memory_in_gbs   = 32 # only used if shape is Flex type
  instance_flex_ocpus           = 2 # only used if shape is Flex type
  ssh_public_keys               = var.ssh_public_key
  block_storage_sizes_in_gbs    = [50]
  shape                         = "VM.Standard.E3.Flex"

  freeform_tags                 = var.freeform_tags
}

module "sddc_security" { 
    source                      = "./modules/sddc/security"
    vcn_id                      = module.vcn.vcn_id 
    compartment_id              = var.compartment_ocid
    vcn_cidr                    = var.vcn_cidr
    sddc_network_enabled        = var.sddc_network_enabled
    is_hcx_enabled              = var.is_hcx_enabled 
    sddc_network_hardened       = var.sddc_network_hardened
    create_service_gateway      = var.create_service_gateway
    workload_network_cidr       = var.workload_network_cidr 

    freeform_tags               = var.freeform_tags
}

module "sddc_network" { 
    source                      = "./modules/sddc/networks"
    sddc_network_enabled        = var.sddc_network_enabled 
    vcn_id                      = module.vcn.vcn_id 
    compartment_id              = var.compartment_ocid
    label_prefix                = var.label_prefix

    # Network Details
    vcn_cidr                    = var.vcn_cidr    
    internal_rt_id              = module.vcn.nat_route_id   
    nat_gateway_entity_id       = module.vcn.nat_gateway_id 
    is_hcx_enabled              = var.is_hcx_enabled     

    sddc_subnet_sl              = module.sddc_security.sddc_subnet_sl
    nsx_edge_uplink_nsg_id      = module.sddc_security.nsx_edge_uplink_nsg_id
    hcx_nsg_id                  = module.sddc_security.hcx_nsg_id
    nsx_edge_vtep_nsg_id        = module.sddc_security.nsx_edge_vtep_nsg_id
    nsx_vtep_nsg_id             = module.sddc_security.nsx_vtep_nsg_id
    provisioning_nsg_id         = module.sddc_security.provisioning_nsg_id
    replication_nsg_id          = module.sddc_security.replication_nsg_id
    vmotion_nsg_id              = module.sddc_security.vmotion_nsg_id
    vsan_nsg_id                 = module.sddc_security.vsan_nsg_id
    vsphere_nsg_id              = module.sddc_security.vsphere_nsg_id

    freeform_tags               = var.freeform_tags
}

module "sddc_cluster" { 
    source                      = "./modules/sddc/cluster"
    sddc_enabled                = var.sddc_enabled
    compartment_id              = var.compartment_ocid
    compute_availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name         
    esxi_hosts_count            = var.esxi_hosts_count
    vmware_software_version     = var.vmware_software_version
    initial_sku                 = var.initial_sku
    label_prefix                = var.label_prefix
    sddc_display_name           = var.sddc_display_name
    
    sddc_network_enabled        = var.sddc_network_enabled
    workload_network_cidr       = var.workload_network_cidr
    internal_rt_id              = module.vcn.nat_route_id 
    ssh_authorized_keys         = var.ssh_public_key
    is_hcx_enabled              = var.is_hcx_enabled           
    provisioning_subnet_id      = module.sddc_network.provisioning_subnet_id
    nsx_edge_uplink1vlan_id     = module.sddc_network.nsx_edge_uplink1vlan_id
    nsx_edge_uplink2vlan_id     = module.sddc_network.nsx_edge_uplink2vlan_id
    nsx_edge_vtep_vlan_id       = module.sddc_network.nsx_edge_vtep_vlan_id
    nsx_vtep_vlan_id            = module.sddc_network.nsx_vtep_vlan_id    
    vsan_vlan_id                = module.sddc_network.vsan_vlan_id
    vsphere_vlan_id             = module.sddc_network.vsphere_vlan_id
    vmotion_vlan_id             = module.sddc_network.vmotion_vlan_id
    provisioning_vlan_id        = module.sddc_network.provisioning_vlan_id
    replication_vlan_id         = module.sddc_network.replication_vlan_id
    hcx_vlan_id                 = module.sddc_network.hcx_vlan_id 

    freeform_tags               = var.freeform_tags         
}


   