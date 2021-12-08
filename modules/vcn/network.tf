# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_subnet" "internal" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, var.newbits, var.netnum)
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "internal" : "${var.label_prefix}-internal"
  dns_label                  = "internal"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.route_table_id
  security_list_ids          = [oci_core_security_list.internal.id, oci_core_security_list.global.id]
  vcn_id                     = var.vcn_id

  freeform_tags = var.freeform_tags
}