# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

##################
# OCI Parameters #
##################

variable "compartment_id" {
  description = "(Required)(Updatable) The OCID of the compartment to contain the route table."
  type        = string
}

variable "vcn_id" {
  description = "OCDI of DR VCN"
  type        = string
}

variable "nat_gateway_entity_id" {
  description = "(Required) The OCID for the route rule's Nat Gateway target"
  type  = string
}

variable "label_prefix" {
  description = "String that will be prepended to all resources"
  type  = string
}

variable "vcn_cidr" {
  description = "CIDR block of VCN"
  type  = string
}

variable "freeform_tags" {
  description = "Simple key-value pairs to tag the resources created using freeform tags"
  type        = map(any)
}

###############################################################
# Security Lists and Network Security Groups for SDD Networks #
###############################################################

# Security List for 
variable "sddc_subnet_sl" {
  description = "OCID of Security List to attach to SDDC subnet"
  type        = string
}

# NSGs for VLAN Security
variable "nsx_edge_uplink_nsg_id" {
  description = "OCID of NSX Edge Uplink VLAN NSG"
  type  = string
}

variable "hcx_nsg_id" {
  description = "OCID of HCX VLAN NSG"
  type  = string
}

variable "nsx_edge_vtep_nsg_id" {
  description = "OCID of NSX Edge VTEP VLAN NSG"
  type  = string
}

variable "nsx_vtep_nsg_id" {
  description = "OCID of NSX VTEP VLAN NSG"
  type  = string
}

variable "provisioning_nsg_id" {
  description = "OCID of Provisioning VLAN NSG"
  type  = string
}

variable "replication_nsg_id" {
  description = "OCID of Replication VLAN NSG"
  type  = string
}

variable "vmotion_nsg_id" {
  description = "OCID of vMotion VLAN NSG"
  type  = string
}

variable "vsan_nsg_id" {
  description = "OCID of vSphere VLAN NSG"
  type  = string
}

variable "vsphere_nsg_id" {
  description = "OCID of vSphere VLAN NSG"
  type  = string
}

###############################
# Additioanl Module variables #
###############################

variable "sddc_network_enabled" {
  # Imported for count to enable/disable sddc network creation
  description = "Whether to deploy SDDC networks. If set to true, creates a SDDC networks"
  type        = bool
}

variable "is_hcx_enabled" {
  description = "Whether to deploy HCX during provisioning. If set to true, HCX is included in the workflow."
  type        = bool  
}

variable "internal_rt_id" {
  # This Route Tabe was provisioned in the VCN Module to provide communication for internal networks. For simplicity reasons, it is used for SDDC Networks that require communication to the VCN, i.e., HCX, vSphere and Uplink VLANS
  description = "OCID of Internal Route Table"
  type        = string
}
