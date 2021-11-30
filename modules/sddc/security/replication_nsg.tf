# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "replication" {
  #Required
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  display_name              = "replication-nsg"
  freeform_tags             = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

#######################################
# Network Security Group Rules
#######################################
# Due to the number of open inbound ports these security rules mirror the hardened rules with the excption to full access form SDDC CIDR
resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = "all"
  source_type = ""
  stateless   = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_2 {
  description               = "Allow all ingress from SDDC CIDR"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = "all"
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_3 {
  description               = "SSH for VCHA replication and communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
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

resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_6 {
  description               = "Monitoring and health pre-checks"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "0"
    type = "0"
  }
  
  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_7 {
  description               = "Monitoring and health pre-checks"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "0"
    type = "8"
  }
  
  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_8 {
  description               = "Traceroute diagnostic traffic"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "0"
    type = "11"
  }

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_rule_9 {
  description               = "Path MTU discovery traffic"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
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

#######################################
# Hardened Network Security Group Rules
#######################################
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = "all"
  source_type = ""
  stateless   = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_2 {
  description               = "SSH for VCHA replication and communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
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

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_3 {
  description               = "Initial Replication 5.8, Ongoing replication traffic 6.x"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.initial_replication_port
      min = local.initial_replication_port
   }
 }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_4 {
  description               = "Ongoing replication traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.ongoing_replication_port
      min = local.ongoing_replication_port
   }
 }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_5 {
  description               = "Monitoring and health pre-checks"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "0"
    type = "0"
  }
  
  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_6 {
  description               = "Monitoring and health pre-checks"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "0"
    type = "8"
  }
  
  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_7 {
  description               = "Traceroute diagnostic traffic"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.icmp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  icmp_options {
    code = "0"
    type = "11"
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_8 {
  description               = "Path MTU discovery traffic"
  destination_type = ""
  direction        = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
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

resource oci_core_network_security_group_security_rule replication_vlan_nsg_hardened_rule_9 {
  description               = "vSphere replication communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.replication[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.iofilter_port
      min = local.iofilter_port
   }
 }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}