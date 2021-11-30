// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Outputs of NSG/SL OCIDS for attachemtn to SDDC VLANs
output "sddc_subnet_sl" {
  description = "OCID of SDDC Subnet SL"
  value       = length(oci_core_security_list.security_list_for_sddc_subnet) > 0 ? oci_core_security_list.security_list_for_sddc_subnet[0].id : ""
}

output "nsx_edge_uplink_nsg_id" {
  description = "OCID of NSX Edge Uplink VLAN NSG"
  value       = length(oci_core_network_security_group.nsx_edge_uplink) > 0 ? oci_core_network_security_group.nsx_edge_uplink[0].id : ""
}

output "hcx_nsg_id" {
  description = "OCID of HCX VLAN NSG"
  value       = length(oci_core_network_security_group.hcx) > 0 ? oci_core_network_security_group.hcx[0].id : ""
}

output "nsx_edge_vtep_nsg_id" {
  description = "OCID of NSX Edge VTEP VLAN NSG"
  value       = length(oci_core_network_security_group.nsx_edge_uplink) > 0 ? oci_core_network_security_group.nsx_edge_vtep[0].id : ""
}

output "nsx_vtep_nsg_id" {
  description = "OCID of NSX VTEP VLAN NSG"
  value       = length(oci_core_network_security_group.nsx_vtep) > 0 ? oci_core_network_security_group.nsx_vtep[0].id : ""
}

output "provisioning_nsg_id" {
  description = "OCID of Provisioning VLAN NSG"
  value       = length(oci_core_network_security_group.provisioning) > 0 ? oci_core_network_security_group.provisioning[0].id : ""
}

output "replication_nsg_id" {
  description = "OCID of Replication VLAN NSG"
  value       = length(oci_core_network_security_group.replication) > 0 ? oci_core_network_security_group.replication[0].id : ""
}

output "vmotion_nsg_id" {
  description = "OCID of vMotion VLAN NSG"
  value       = length(oci_core_network_security_group.vmotion) > 0 ? oci_core_network_security_group.vmotion[0].id : ""
}

output "vsan_nsg_id" {
  description = "OCID of VSAN VLAN NSG"
  value       = length(oci_core_network_security_group.vsan) > 0 ? oci_core_network_security_group.vsan[0].id : ""
}

output "vsphere_nsg_id" {
  description = "OCID of vSphere VLAN NSG"
  value       = length(oci_core_network_security_group.vsphere) > 0 ? oci_core_network_security_group.vsphere[0].id : ""
}

