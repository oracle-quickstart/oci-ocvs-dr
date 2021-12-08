# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "provisioning" {
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  display_name              = "provisioning-nsg"
  freeform_tags             = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0
}

#######################################
# Network Security Group Rules
#######################################
resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = "all"
  source_type               = ""
  stateless                 = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_rule_3 {
  description               = "Allow all ingress from VCN CIDR"
  source                    = var.vcn_cidr
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = "all"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && !var.sddc_network_hardened ? 1 : 0
}

#######################################
# Hardened Network Security Group Rules
#######################################
#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_1 {
  description               = "Allow all egress traffic"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = "all"
  source_type               = ""
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_2 {
  description               = "Allow NTP port traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.ntp_port
      min = local.ntp_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_3 {
  description               = "Allow SSH traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
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

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_4 {
  description               = "Allow traffic for NSX messaging channel to NSX Manager"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.nsx_msg_min_port
      min = local.nsx_msg_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_5 {
  description               = "Allow traffic for vSAN Cluster Monitoring, Membership, and Directory Service"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vsan_cluster_max_port
      min = local.vsan_cluster_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_6 {
  description               = "Allow Unicast agent traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_7 {
  description               = "Allow NestDB traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.nestdb_port
      min = local.nestdb_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_8 {
  description               = "Allow iSCSI traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.iscsi_port
      min = local.iscsi_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_9 {
  description               = "Allow BFD traffic between nodes"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.bfd_max_port
      min = local.bfd_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_10 {
  description               = "Allow Edge HA traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.nsx_edge_ha_port
      min = local.nsx_edge_ha_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_11 {
  description               = "Allow NSX Agent traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.nsx_agent_port
      min = local.nsx_agent_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_12 {
  description               = "Allow AMQP traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.amqp_port
      min = local.amqp_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_13 {
  description               = "Allow NSX messaging traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.nsx_msg_max_port
      min = local.nsx_msg_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_14 {
  description               = "Allow HTTP traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.http_alt_port
      min = local.http_alt_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_15 {
  description               = "Allow RFB protocol traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.rfb_max_port
      min = local.rfb_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_16 {
  description               = "Allow ESXi dump collector traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.esxi_dump_port
      min = local.esxi_dump_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_17 {
  description               = "Allow ESXi dump collector traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.esxi_dump_port
      min = local.esxi_dump_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_18 {
  description               = "Allow NSX Edge communication traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.nsx_edge_port
      min = local.nsx_edge_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_19 {
  description               = "Allow NSX DLR traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.nsx_dlr_port
      min = local.nsx_dlr_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_20 {
  description               = "Allow vSphere fault tolerance traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.ft_max_port
      min = local.ft_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_21 {
  description               = "Allow vSphere fault tolerance traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.ft_max_port
      min = local.ft_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_22 {
  description               = "Allow vMotion traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_23 {
  description               = "Allow vMotion traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vmotion_port
      min = local.vmotion_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_24 {
  description               = "Allow vSAN health traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.vsan_health_max_port
      min = local.vsan_health_max_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_25 {
  description               = "Allow vSAN health traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_26 {
  description               = "Allow vSAN health traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_27 {
  description               = "Allow traffic to DVSSync port to enable fault tolerance"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.dvs_max_port
      min = local.dvs_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_28 {
  description               = "Allow Web Services Management traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.web_svc_port
      min = local.web_svc_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_29 {
  description               = "Allow Distributed Data Store traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.dist_ds_port
      min = local.dist_ds_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_30 {
  description               = "Allow Distributed Data Store traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.dist_ds_port
      min = local.dist_ds_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_31 {
  description               = "Allow vCenter Server to manage ESXi hosts"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_32 {
  description               = "Allow Server Agent traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vcenter_agent_port
      min = local.vcenter_agent_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_33 {
  description               = "Allow I/O Filter traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_34 {
  description               = "Allow ingress traffic for VMware inter-process communication"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = "all"
  source                    = local.sddc_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_35 {
  description               = "Allow RDT traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.rdt_port
      min = local.rdt_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_36 {
  description               = "Allow CIM client traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.cim_port
      min = local.cim_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_37 {
  description               = "Allow CIM client traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.cim_port
      min = local.cim_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_38 {
  description               = "Allow HTTPS traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.https_port
      min = local.https_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_39 {
  description               = "Allow DNS traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.dns_port
      min = local.dns_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_40 {
  description               = "Allow DNS traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.dns_port
      min = local.dns_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_41 {
  description               = "Allow systemd-resolve traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.systemd_port
      min = local.systemd_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_42 {
  description               = "Allow appliance management traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.vami_port
      min = local.vami_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_43 {
  description               = "Allow CIM traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.cim_max_port
      min = local.cim_min_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_44 {
  description               = "Allow HTTP traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
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

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_45 {
  description               = "Allow vSphere Web Client traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.vsphere_web_port
      min = local.vsphere_web_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_46 {
  description               = "Allow vSphere Web Client traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.vsphere_web_port
      min = local.vsphere_web_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_47 {
  description               = "Allow vSphere Web Client traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = local.rest_api_port
      min = local.rest_api_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_48 {
  description               = "Allow vSphere Web Client traffic"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = local.rest_api_port
      min = local.rest_api_port
    }
  }

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_49 {
  description               = "Allow traffic to TCP ports for VMware cluster"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.tcp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}

resource oci_core_network_security_group_security_rule provisioning_vlan_nsg_security_hardened_rule_50 {
  description               = "Allow traffic to UDP ports for VMware cluster"
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.provisioning[0].id
  protocol                  = local.udp_protocol
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"

  count = var.sddc_network_enabled && var.sddc_network_hardened ? 1 : 0
}
