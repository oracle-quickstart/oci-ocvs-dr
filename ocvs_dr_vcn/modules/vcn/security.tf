# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

########################
# Security Lists SL
########################

#global_sl applied to all subnets to allow outbound traffic and limited ping request
resource "oci_core_security_list" "global" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.label_prefix == "none" ? "global" : "${var.label_prefix}-global"

  // allow outbound traffic on all ports
  egress_security_rules {
    description = "Allow all outbound traffic"
    destination_type = "CIDR_BLOCK"
    destination = local.anywhere
    protocol    = "all"
    stateless   = false
  }

  // Allow ICMP traffic type 3 (all codes) from your VCN's CIDR block. This rule makes it easy for your instances to receive connectivity error messages from other instances within the VCN.
  ingress_security_rules {
    source_type = "CIDR_BLOCK"
    protocol    = local.icmp_protocol
    source      = var.vcn_cidr
    stateless   = true

    icmp_options {
      type = 3
    }
  }

  // Allow ICMP traffic type 3 code 4 from authorized source IP addresses. This rule enables your instances to receive Path MTU Discovery fragmentation messages
  ingress_security_rules {
    source_type = "CIDR_BLOCK"
    protocol    = local.icmp_protocol
    source      = local.anywhere
    stateless   = true

    icmp_options {
      type = 3
      code = 4
    }
  }
}

# Assigned to internal VCN traffic
resource "oci_core_security_list" "internal" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.label_prefix == "none" ? "internal" : "${var.label_prefix}-internal"
  
  // allow inbound ssh traffic from a specific port
  ingress_security_rules {
    description = "Allow all local VCN traffic"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    source      = var.vcn_cidr
    stateless   = false
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    description = "Allow all worload traffic"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    source      = var.workload_network_cidr
    stateless   = false
  }
  
  // allow access to oci services
  egress_security_rules {
    destination      = data.oci_core_services.test_services.services[0]["cidr_block"]
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "all"
  }
}
