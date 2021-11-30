// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
/*
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = var.create_service_gateway == true ? 1 : 0
}

*/


// Get all availability domains for the region
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}


/* Enable to gain visibility to updated parameters
data "oci_ocvp_supported_skus" "supported_skus" {
  compartment_id = "${var.compartment_ocid}"
}

data "oci_ocvp_supported_vmware_software_versions" "supported_vmware_software_versions" {
  compartment_id = "${var.compartment_ocid}"
}
*/

