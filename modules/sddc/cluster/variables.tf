# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

##################
# OCI Parameters #
##################

variable "compartment_id" {
  description = "(Required) (Updatable) The OCID of the compartment to contain the SDDC."
  type        = string
}

variable "compute_availability_domain" {
  description = "(Required) The Availability Domain to create the SDDC cluster. Default is set to AD1 in main.tf"
  type        = string
}

variable "label_prefix" {
  description = "A string that will be prepended to all resource display names"
  type        = string
}

##################
# SDDC Parameters#
##################

# ** IMPORTANT ** Any change to a property that does not support update will force the destruction and recreation of the resource with the new property values

variable "sddc_enabled" {
  description = "Whether to deploy SDDC Cluster. If set to true, creates a SDDC Cluster."  
  type        = bool
}

variable "sddc_display_name" {
  description = "(Optional) (Updatable) A descriptive name for the SDDC. SDDC name requirements are 1-16 character length limit, Must start with a letter, Must be English letters, numbers, - only, No repeating hyphens, Must be unique within the region. Avoid entering confidential information."
  type        = string
}

variable "esxi_hosts_count" {
  description = "(Required) The number of ESXi hosts to create in the SDDC. Changing this value post-deployment will delete the entire cluster. You can add more hosts in the OCI GUI following the initial deployment"
  type        = number
}

variable "vmware_software_version" {
  description = "(Required) The VMware software bundle to install on the ESXi hosts in the SDDC. To get a list of the available versions. Documentation states updateable but that's incorrect. DO NOT UPDATE POST-DEPLOYMENT"
  type        = string
}

variable "initial_sku" {  
  # Oracle Cloud Infrastructure VMware Solution supports the following billing interval SKUs: HOUR, MONTH, ONE_YEAR, and THREE_YEARS
  # https://docs.oracle.com/en-us/iaas/api/#/en/vmware/20200501/SupportedSkuSummary/ListSupportedSkus
  description = "Contract Length"
  type        = string
}

variable "workload_network_cidr" {
  description = "(Optional) The CIDR block for the IP addresses that VMware VMs in the SDDC use to run application workloads."  
  type = string
}

variable "ssh_authorized_keys" {
  description = "(Required) (Updatable) One or more public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on each ESXi host. Use a newline character to separate multiple keys. The SSH keys must be in the format required for the authorized_keys file"
  type        = string
}

variable "is_hcx_enabled" {
  description = "Whether to deploy HCX during provisioning. If set to true, HCX is included in the workflow."
  type        = bool  
}

variable "sddc_network_enabled" {
  # Imported for count to enable/disable sddc network creation
  description = "Whether to deploy SDDC networks. If set to true, creates a SDDC networks"
  type        = bool
}

##########################
# Subnets/VLANs for SDDC #
##########################
variable "provisioning_subnet_id" { 
  description = "(Required) The OCID of the management subnet to use for provisioning the SDDC"
  type        = string
}

variable "nsx_edge_uplink1vlan_id" {
  description = "(Required)(Updatable) The OCID of the VLAN to use for the NSX Edge Uplink 1 component of the VMware environment"
  type        = string
}

variable "nsx_edge_uplink2vlan_id" {
  description = " (Required)(Updatable) The OCID of the VLAN to use for the NSX Edge Uplink 2 component of the VMware environment"
  type        = string
}

variable "nsx_vtep_vlan_id" {
  description = "(Required)(Updatable) The OCID of the VLAN to use for the NSX VTEP component of the VMware environment"
  type        = string
}

variable "nsx_edge_vtep_vlan_id" {
  description = "(Required)(Updatable) The OCID of the VLAN to use for the NSX Edge VTEP component of the VMware environment"
  type        = string
}

variable "vsan_vlan_id" {
  description = "(Required)(Updatable) The OCID of the VLAN to use for the vSAN component of the VMware environment"
  type        = string
}

variable "vmotion_vlan_id" {
  description = "(Required)(Updatable) The OCID of the VLAN to use for the vMotion component of the VMware environment"
  type        = string
}

variable "vsphere_vlan_id" {
  description = "(Required)(Updatable) The OCID of the VLAN to use for the vMotion component of the VMware environment"
  type        = string
}

variable "hcx_vlan_id" {
  description = "(Optional)(Updatable) The OCID of the VLAN to use for the HCX component of the VMware environment. This value is required only when isHcxEnabled is true"
  type        = string
}

variable "provisioning_vlan_id" {
  description = "(Optional)(Updatable) The OCID of the VLAN used by the SDDC for the Provisioning component of the VMware environment."
  type        = string
}

variable "replication_vlan_id" {
  description = "(Optional) (Updatable) The OCID of the VLAN used by the SDDC for the vSphere Replication component of the VMware environment."
  type        = string
}

###############################
# Additioanl Module variables #
###############################

variable "internal_rt_id" {
  # This Route Tabe was provisioned in the VCN Module to provide communication for internal networks. For simplicity reasons, it is used for SDDC Networks that require communication to the VCN, i.e., HCX, vSphere and Uplink VLANS
  description = "OCID of Internal Route Table"
  type        = string
}

variable "freeform_tags" {
  description = "simple key-value pairs to tag the resources created using freeform tags."
  type        = map(any)
}