# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "nsx_edge_uplink_ip" {
  description = "Virtual IP (VIP) for the NSX Edge Uplink"
  value       = length(oci_ocvp_sddc.dr_sddc) > 0 ? oci_ocvp_sddc.dr_sddc[0].nsx_edge_uplink_ip_id : ""
}

output "vcenter_fqdn" {
  description = "vCenter Private IP"
  value       = length(oci_ocvp_sddc.dr_sddc) > 0 ? oci_ocvp_sddc.dr_sddc[0].vcenter_fqdn : ""
}

# If enabled, sensitive information will be stored in state file. 
/*
output "vcenter_username" {
  description = "vCenter Admin/SSO username"
  value       = length(oci_ocvp_sddc.dr_sddc) > 0 ? oci_ocvp_sddc.dr_sddc[0].vcenter_username : ""
}

output "vcenter_initial_password" {
  description = "Initial vCenter Password"
  value       = length(oci_ocvp_sddc.dr_sddc) > 0 ? oci_ocvp_sddc.dr_sddc[0].vcenter_initial_password : ""
}
*/
