# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

variable "vcn_id" {
  description = "OCDI of DR VCN"
  type        = string
}

variable "compartment_id" {
  description = "OCID of compartment where DR resources will be managed"
  type        = string
}

variable "vcn_cidr" {  
  description = "cidr block of VCN"
  type = string  
}

variable "netnum" {
  description = "0-based index of the bastion subnet when the VCN's CIDR is masked with the corresponding newbit value."
  type        = number
}

variable "newbits" {
  description = "The difference between the VCN's netmask and the desired bastion subnet mask"
  type        = number
}

variable "workload_network_cidr" {
  description = "cidr block of SDDC workloads"
  type = string
}

variable "label_prefix" {
  #If "none" resources will inherit vcn_name only.
  description = "a string that will be prepended to all resources"
  type        = string
 }

variable "freeform_tags" {
  description = "Simple key-value pairs to tag the resources created using freeform tags"
  type        = map(any)
}
/*
variable "cidr_block" {  
  description = "cidr block of VCN"
  type = string  
}
*/
variable "route_table_id" {
  description = "id of route table for internal subnet"
  type        = string
}
