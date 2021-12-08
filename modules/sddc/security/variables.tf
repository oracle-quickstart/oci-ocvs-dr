# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

##################
# OCI Parameters #
##################

variable "compartment_id" {
  description = "OCID from your tenancy page"
  type        = string
}

variable "vcn_id" {
  description = "OCDI of DR VCN"
  type        = string
}

variable "vcn_cidr" {
  description = "cidr block of VCN"
  type        = string
}

variable "freeform_tags" {
  description = "simple key-value pairs to tag the resources created using freeform tags."
  type        = map(any)
}

###############################
# Additioanl Module variables #
###############################

variable "sddc_network_enabled" {
  # Imported for count to enable/disable sddc network creation
  description = "whether to deploy SDDC networks. If set to true, creates a SDDC networks"
  type        = bool
}

variable "is_hcx_enabled" {
  description = "Whether to deploy HCX during provisioning. If set to true, HCX is included in the workflow."
  type        = bool  
}

variable "sddc_network_hardened" {
  # Imported for count to enable/disable sddc network hardening
  description = "whether to apply hardening rules to SDDC networks"
  type        = bool
}

variable "create_service_gateway" {
  #! Deprecation notice: will be renamed to create_service_gateway at next major release
  description = "Whether to create a service gateway. If set to true, creates a service gateway."
  type        = bool
}

variable "workload_network_cidr" {
  description = "(Optional) The CIDR block for the IP addresses that VMware VMs in the SDDC use to run application workloads."  
  type = string
}