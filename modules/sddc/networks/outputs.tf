# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# SDDC network ouputs for use in sddc_cluster module

#subnets
output "provisioning_subnet_id" {
  description = "OCID of Provisioning Subnet"
  value       = length(oci_core_subnet.provisioning_subnet) > 0 ? oci_core_subnet.provisioning_subnet[0].id : ""
}

#vlans
output "nsx_edge_uplink1vlan_id" {
  description = "OCID of NSX Edge Uplink 1 VLAN"
  value       = length(oci_core_vlan.nsx_edge_uplink1_vlan) > 0 ? oci_core_vlan.nsx_edge_uplink1_vlan[0].id : ""
}

output "nsx_edge_uplink2vlan_id" {
  description = "OCID of NSX Edge Uplink 2 VLAN"
  value       = length(oci_core_vlan.nsx_edge_uplink2_vlan) > 0 ? oci_core_vlan.nsx_edge_uplink2_vlan[0].id : ""
}

output "nsx_vtep_vlan_id" {
  description = "OCID of NSX VTEP VLAN"
  value       = length(oci_core_vlan.nsx_vtep_vlan) > 0 ? oci_core_vlan.nsx_vtep_vlan[0].id : ""
}

output "nsx_edge_vtep_vlan_id" {
  description = "OCID of NSX Edge VTEP VLAN"
    value       = length(oci_core_vlan.nsx_edge_vtep_vlan) > 0 ? oci_core_vlan.nsx_edge_vtep_vlan[0].id : ""
}

output "vsan_vlan_id" {
  description = "OCID of VSAN VLAN"
   value       = length(oci_core_vlan.vsan_vlan) > 0 ? oci_core_vlan.vsan_vlan[0].id : ""
}

output "vmotion_vlan_id" {
  description = "OCID of vMotion VLAN"
   value       = length(oci_core_vlan.vmotion_vlan) > 0 ? oci_core_vlan.vmotion_vlan[0].id : ""
}

output "vsphere_vlan_id" {
  description = "OCID of vSphere VLAN"
    value       = length(oci_core_vlan.vsphere_vlan) > 0 ? oci_core_vlan.vsphere_vlan[0].id : ""
}

output "hcx_vlan_id" {
  description = "OCID of HCX VLAN"
  value       = length(oci_core_vlan.hcx_vlan) > 0 ? oci_core_vlan.hcx_vlan[0].id : ""
}

output "provisioning_vlan_id" {
  description = "OCID of Provisioning VLAN"
  value       = length(oci_core_vlan.provisioning_vlan) > 0 ? oci_core_vlan.provisioning_vlan[0].id : ""
}

output "replication_vlan_id" {
  description = "OCID of Replication VLAN"
  value       = length(oci_core_vlan.replication_vlan) > 0 ? oci_core_vlan.replication_vlan[0].id : ""
}