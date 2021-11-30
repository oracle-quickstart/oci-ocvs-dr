# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "nsx_edge_uplink" {
  #Required
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  display_name              = "nsx-edge-uplink-nsg"
  freeform_tags             = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

#######################################
# Network Security Group Rules
#######################################
#Due to required anywhere access hardening rules intact with one additional rulle allowing inbound traffic from VCN
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source_type = ""
  stateless   = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_2 {
  description               = "Allow SSH traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = local.tcp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.ssh_port
      min = local.ssh_port
    }
  }

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_3 {
  description               = "ICMP traffic for: 3, 4 Destination Unreachable: Fragmentation Needed and Don't Fragment was Set"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"  
  icmp_options {
    code = "4"
    type = "3"
  }

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0  
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_4 {
  description               = "ICMP traffic for: 3 Destination Unreachable"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "-1"
    type = "3"
  }
  
  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_6 {
  description               = "Allow all ingress from VCN CIDR"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_7 {
  description               = "Access to OCI Services"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source                    = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
  source_type               = "SERVICE_CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_rule_8 {
  description               = "Access to OCI Services"
  destination               = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
  destination_type          = "SERVICE_CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source_type               = ""
  stateless                 = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}


#######################################
# Hardened Network Security Group Rules
#######################################
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source_type = ""
  stateless   = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_2 {
  description               = "Allow SSH traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = local.tcp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.ssh_port
      min = local.ssh_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_3 {
  description               = "ICMP traffic for: 3, 4 Destination Unreachable: Fragmentation Needed and Don't Fragment was Set"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"  
  icmp_options {
    code = "4"
    type = "3"
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0  
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_4 {
  description               = "ICMP traffic for: 3 Destination Unreachable"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "-1"
    type = "3"
  }
  
  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_5 {
  description               = "Allow ingress traffic for VMware inter-process communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_6 {
  description               = "Access to OCI Services"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source                    = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
  source_type               = "SERVICE_CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule nsx_edge_uplink_vlan_nsg_hardened_rule_7 {
  description               = "Access to OCI Services"
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination               = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.nsx_edge_uplink[0].id
  protocol                  = "all"
  source_type               = ""
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}


