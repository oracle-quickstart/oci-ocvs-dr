# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "vsan" {
  #Required
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  display_name              = "vsan-nsg"
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
resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = "all"
  source_type = ""
  stateless   = "false"

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_2 {
  description               = "Allow traffic used for Virtual SAN health monitoring"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.vsan_health_port
      min = local.vsan_health_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_3 {
  description               = "Allow traffic used for Virtual SAN health monitoring"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vsan_health_port
      min = local.vsan_health_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_4 {
  description               = "Allow vSAN HTTP traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.http_port
      min = local.http_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_5 {
  description               = "Allow vSAN Transport traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.rdt_port
      min = local.rdt_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_6 {
  description               = "Allow vSAN Clustering Service traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vsan_cluster_min_port
      min = local.vsan_cluster_min_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_7 {
  description               = "Allow Unicast agent traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.unicast_agent_port
      min = local.unicast_agent_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_8 {
  description               = "Allow vSAN Clustering Service traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vsan_cluster_max_port
      min = local.vsan_cluster_max_port
    }
  }

  count = var.sddc_network_enabled && true ? 1 : 0
}

resource oci_core_network_security_group_security_rule vsan_vlan_nsg_hardened_rule_9 {
  description               = "Allow ingress traffic for VMware inter-process communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.vsan[0].id
  protocol                  = "all"
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && true ? 1 : 0
}