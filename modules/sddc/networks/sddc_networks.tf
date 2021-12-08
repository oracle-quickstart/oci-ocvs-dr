# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# About SDDC Layer 2 Networking Resources - https://docs.oracle.com/en-us/iaas/Content/VMware/Tasks/ocvsmanagingl2net.htm
# cidrsubnet calculation tool - https://blog.ebfe.pw/posts/ipcalcterraform.html

#Subnet
resource "oci_core_subnet" "provisioning_subnet" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 16)
  compartment_id             = var.compartment_id
  #dhcp_options_id            = oci_core_vcn.vcn_ocvp.default_dhcp_options_id
  display_name               = var.label_prefix == "none" ? "sddc-provisioning" : "${var.label_prefix}-sddc-provisioning"
  dns_label                  = "provisioningsub"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  security_list_ids          = [var.sddc_subnet_sl]
  vcn_id                     = var.vcn_id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0 
}

#VLANs
resource "oci_core_vlan" "nsx_edge_uplink1_vlan" {
  display_name               = var.label_prefix == "none" ? "nsx edge uplink 1" : "${var.label_prefix}-nsx edge uplink 1"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 17)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.nsx_edge_uplink_nsg_id]
  route_table_id             = var.internal_rt_id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "nsx_edge_uplink2_vlan" {
  display_name               = var.label_prefix == "none" ? "nsx edge uplink 2" : "${var.label_prefix}-nsx edge uplink 2"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 18)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.nsx_edge_uplink_nsg_id]
  route_table_id             = var.internal_rt_id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "nsx_vtep_vlan" {
  display_name               = var.label_prefix == "none" ? "nsx vtep vlan" : "${var.label_prefix}-nsx vtep vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 20)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.nsx_vtep_nsg_id]
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "nsx_edge_vtep_vlan" {
  display_name               = var.label_prefix == "none" ? "nsx edge vtep vlan" : "${var.label_prefix}-nsx edge vtep vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 19)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.nsx_edge_vtep_nsg_id]
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "vsan_vlan" {
  display_name               = var.label_prefix == "none" ? "vsan vlan" : "${var.label_prefix}-vsan vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 22)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.vsan_nsg_id]
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "vmotion_vlan" {
  display_name               = var.label_prefix == "none" ? "vmotion vlan" : "${var.label_prefix}-vmotion vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 21)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.vmotion_nsg_id]
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "vsphere_vlan" {
  display_name               = var.label_prefix == "none" ? "vsphere vlan" : "${var.label_prefix}-vsphere vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 6, 46)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.vsphere_nsg_id]
  route_table_id             = var.internal_rt_id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "hcx_vlan" {
  display_name               = var.label_prefix == "none" ? "hcx vlan" : "${var.label_prefix}-hcx vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 6, 47)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.hcx_nsg_id]
  route_table_id             = var.internal_rt_id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled && var.is_hcx_enabled ? 1 : 0
}

resource "oci_core_vlan" "provisioning_vlan" {
  display_name               = var.label_prefix == "none" ? "provisioning vlan" : "${var.label_prefix}-provisioning vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 25)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.provisioning_nsg_id]
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

resource "oci_core_vlan" "replication_vlan" {
  display_name               = var.label_prefix == "none" ? "replication vlan" : "${var.label_prefix}-replication vlan"
  cidr_block                 = cidrsubnet(var.vcn_cidr, 5, 24)
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  nsg_ids                    = [var.replication_nsg_id]
  route_table_id             = oci_core_route_table.sddc_internal[0].id
  freeform_tags              = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}