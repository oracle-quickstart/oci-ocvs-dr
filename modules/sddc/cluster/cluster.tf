# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Resource Doc - https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ocvp_sddc
# It's advised to review the documention before changing any values post-deployment. Some values may triger a deletion of the entire cluster that could result in data loss. 
 
resource "oci_ocvp_sddc" "dr_sddc" {
  // Required
  display_name                 = var.label_prefix == "none" ? var.sddc_display_name : "${var.label_prefix}-${var.sddc_display_name}"
  compartment_id               = var.compartment_id
  compute_availability_domain  = var.compute_availability_domain
  esxi_hosts_count             = var.esxi_hosts_count
  vmware_software_version      = var.vmware_software_version
  is_hcx_enabled               = var.is_hcx_enabled
  workload_network_cidr        = var.workload_network_cidr
  initial_sku                  = var.initial_sku 
  ssh_authorized_keys          = var.ssh_authorized_keys

  hcx_vlan_id                  = var.hcx_vlan_id   
  nsx_edge_uplink1vlan_id      = var.nsx_edge_uplink1vlan_id 
  nsx_edge_uplink2vlan_id      = var.nsx_edge_uplink2vlan_id
  nsx_edge_vtep_vlan_id        = var.nsx_edge_vtep_vlan_id 
  nsx_vtep_vlan_id             = var.nsx_vtep_vlan_id
  provisioning_subnet_id       = var.provisioning_subnet_id  
  vmotion_vlan_id              = var.vmotion_vlan_id  
  vsan_vlan_id                 = var.vsan_vlan_id  
  vsphere_vlan_id              = var.vsphere_vlan_id
  provisioning_vlan_id         = var.provisioning_vlan_id
  replication_vlan_id          = var.replication_vlan_id

  freeform_tags                = var.freeform_tags

  count = var.sddc_network_enabled && var.sddc_enabled ? 1 : 0
  
  # Optional 
  #reserving_hcx_on_premise_license_keys = var.reserving_hcx_on_premise_license_keys
  #defined_tags  = {"${oci_identity_tag_namespace.tag-namespace1.name}.${oci_identity_tag.tag1.name}" = "${var.sddc_defined_tags_value}"}
  #display_name  = var.sddc_display_name
  #instance_display_name_prefix = "prefix"
  #hcx_action = "upgrade"
  #refresh_hcx_license_status = true
  
}

// If unmasked, triggers Oracle Route Table Utility to update VCN Internal Route table with SDDC NSX Segment route. Requires Python, please see README for additional details. 

/*
resource "null_resource" "internal_route_table_update" {
  triggers = {
    rt_id                 = var.internal_rt_id
    cidr                  = var.workload_network_cidr
    nsx_edge_uplink_ip_id = oci_ocvp_sddc.dr_sddc[0].nsx_edge_uplink_ip_id
  }

  provisioner "local-exec" {
    command = "ortu --rt-ocid ${self.triggers.rt_id} --cidr ${self.triggers.cidr} --ne-ocid ${self.triggers.nsx_edge_uplink_ip_id}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "ortu delete --rt-ocid ${self.triggers.rt_id} --cidr ${self.triggers.cidr} --ne-ocid ${self.triggers.nsx_edge_uplink_ip_id}"
  }
  count = var.sddc_network_enabled && var.sddc_enabled ? 1 : 0
}
*/

// unmask each resource to add addiitoanl hosts to the existing cluster

/*
resource "oci_ocvp_esxi_host" "add_esxi_host1" {
    #Required
    sddc_id = oci_ocvp_sddc.test_sddc.id

    #Optional
    compute_availability_domain = var.esxi_host_compute_availability_domain
    current_sku = var.esxi_host_current_sku
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.esxi_host_display_name
    freeform_tags = {"Department"= "Finance"}
    next_sku = var.esxi_host_next_sku
}
*/

/*
resource "oci_ocvp_esxi_host" "add_esxi_host2" {
    #Required
    sddc_id = oci_ocvp_sddc.test_sddc.id

    #Optional
    compute_availability_domain = var.esxi_host_compute_availability_domain
    current_sku = var.esxi_host_current_sku
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.esxi_host_display_name
    freeform_tags = {"Department"= "Finance"}
    next_sku = var.esxi_host_next_sku
}
*/

/*
resource "oci_ocvp_esxi_host" "add_esxi_host3"{
    #Required
    sddc_id = oci_ocvp_sddc.test_sddc.id

    #Optional
    compute_availability_domain = var.esxi_host_compute_availability_domain
    current_sku = var.esxi_host_current_sku
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.esxi_host_display_name
    freeform_tags = {"Department"= "Finance"}
    next_sku = var.esxi_host_next_sku
}
*/

/*
resource "oci_ocvp_esxi_host" "add_esxi_host4"{
    #Required
    sddc_id = oci_ocvp_sddc.test_sddc.id

    #Optional
    compute_availability_domain = var.esxi_host_compute_availability_domain
    current_sku = var.esxi_host_current_sku
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.esxi_host_display_name
    freeform_tags = {"Department"= "Finance"}
    next_sku = var.esxi_host_next_sku
}
*/