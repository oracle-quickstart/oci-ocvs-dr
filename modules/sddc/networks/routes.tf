# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_route_table" "sddc_internal" {
  # Route table for SDDC networks requiring only NAT connectivity
  compartment_id      = var.compartment_id
  display_name        = var.label_prefix == "none" ? "sddc-internal" : "${var.label_prefix}-sddc-internal"
  vcn_id              = var.vcn_id

  freeform_tags       = var.freeform_tags

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.nat_gateway_entity_id
    description       = "NAT Gateway Traffic"
  }

  count = var.sddc_network_enabled == true ? 1 : 0
}