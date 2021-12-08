# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "hcx" {
  #Required
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  display_name              = "hcx-nsg"
  freeform_tags             = var.freeform_tags

  count = var.sddc_network_enabled && var.is_hcx_enabled ? 1 : 0
}

#######################################
# Network Security Group Rules
#######################################
resource oci_core_network_security_group_security_rule hcx_vlan_nsg_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = "all"
  source_type               = ""
  stateless                 = "false"

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == false ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_rule_2 {
  description               = "Allow all ingress from SDDC Workload Segment"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = "all"
  source                    = var.workload_network_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == false ? 1 : 0
 }

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_rule_3 {
  description               = "Allow all ingress from VCN CIDR"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = "all"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == false ? 1 : 0
}

#######################################
# Hardened Network Security Group Rules
#######################################
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = "all"
  source_type               = ""
  stateless                 = "false"

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_2 {
  description               = "Allow HCX bulk migration traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
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

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_3 {
  description               = "Allow HCX X-cloud vMotion traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.vmotion_port
      min = local.vmotion_port
    }
  }

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_4 {
  description               = "Allow HCX X-cloud control traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.https_port
      min = local.https_port
    }
  }

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_5 {
  description               = "Allow HCX REST API traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.rest_api_port
      min = local.rest_api_port
    }
  }

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_6 {
  description               = "Allow HCX cold migration traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.vcenter_agent_port
      min = local.vcenter_agent_port
    }
  }

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_7 {
  description               = "Allow OVF import traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.http_port
      min = local.http_port
    }
  }

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

resource oci_core_network_security_group_security_rule hcx_vlan_nsg_hardened_rule_8 {
  description               = "Allow HCX WAN transport traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.hcx[0].id
  protocol                  = local.udp_protocol
  source                    = local.anywhere
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.hcx_wan_port
      min = local.hcx_wan_port
    }
  }

  count = length(oci_core_network_security_group.hcx) > 0 && var.sddc_network_hardened == true ? 1 : 0
}

