# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "nsx_edge_vtep" {
  #Required
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  display_name              = "nsx-edge-vtep-nsg"
  freeform_tags             = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

#######################################
# Network Security Group Rules
#######################################
#Left hardening rules intact.
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm

#######################################
# Hardened Network Security Group Rules
#######################################
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_network_security_group_security_rule nsx_edge_vtep_vlan_nsg_hardened_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_vtep[0].id
  protocol                  = "all"
  source_type = ""
  stateless   = "false"

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_vtep_vlan_nsg_hardened_rule_2 {
  description = "Allow traffic for GENEVE Termination End Point (TEP) Transport N/W"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_vtep[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.geneve_port
      min = local.geneve_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_vtep_vlan_nsg_hardened_rule_3 {
  description = "Allow traffic for BFD Session between TEPs"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_vtep[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.bfd_max_port
      min = local.bfd_min_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_vtep_vlan_nsg_hardened_rule_4 {
  description = "Allow ingress traffic for VMware inter-process communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_vtep[0].id
  protocol                  = "all"
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && true ? 1 : 0
}

