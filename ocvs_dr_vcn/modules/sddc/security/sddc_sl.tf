# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

#Rules based on OCVS hardening best practices - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm
resource oci_core_security_list security_list_for_sddc_subnet {
  compartment_id     = var.compartment_id
  vcn_id             = var.vcn_id
  display_name       = "sddc-internal"
  freeform_tags      = var.freeform_tags

  count = var.sddc_network_enabled == true ? 1 : 0

  egress_security_rules {
    description      = "Allow all egress traffic"
    destination      = local.anywhere
    destination_type = "CIDR_BLOCK"    
    protocol         = "all"
    stateless        = "false"  
  }

  ingress_security_rules {
    description      = "Allow SSH traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
   }    
 }

  ingress_security_rules {
    description      = "Allow ICMP traffic"
    protocol         = local.icmp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
  } 

  ingress_security_rules {
    description      = "Allow HTTP traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.http_port
      min = local.http_port      
    } 
  }

  ingress_security_rules {
    description      = "Allow HTTPS traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.https_port
      min = local.https_port      
    } 

  }

  ingress_security_rules {
    description      = "Allow vCenter Server agent to manage ESXi host"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.hcx_cold_port
      min = local.hcx_cold_port
    }   
  }

  ingress_security_rules {
    description      = "Allow vCenter Server agent to manage ESXi host"
    protocol         = local.udp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    udp_options {
      max = local.hcx_cold_port
      min = local.hcx_cold_port      
    }
  }

  ingress_security_rules {
    description      = "Allow vCenter Server agent to manage ESXi host"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.vcenter_port
      min = local.vcenter_port
    }
  }

  ingress_security_rules {
    description      = "Allow DNS traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.ntp_port
      min = local.ntp_port      
    }
  }

  ingress_security_rules {
    description      = "Allow DNS traffic"
    protocol         = local.udp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    #tcp_options = <<Optional value not found in discovery>>
    udp_options {
      max = local.ntp_port
      min = local.ntp_port
    }
  }

  ingress_security_rules {
    description      = "Allow VMware license server traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.license_max_port
      min = local.license_max_port
    }
  }

  ingress_security_rules {
    description      = "Allow VMware license server traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.license_min_port
      min = local.license_min_port
    }
  }

  ingress_security_rules {
    description      = "Allow NTP time server traffic"
    protocol         = local.udp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    udp_options {
      max = local.ntp_port
      min = local.ntp_port
    }
  }

  ingress_security_rules {
    description      = "Allow iSCSI traffic"
    protocol         = local.tcp_protocol
    source           = var.vcn_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
    tcp_options {
      max = local.iscsi_port
      min = local.iscsi_port
    }
  }

  ingress_security_rules {
    description      = "Allow ingress traffic for VMware inter-process communication"
    protocol         = "all"
    source           = local.sddc_cidr
    source_type      = "CIDR_BLOCK"
    stateless        = "false"
  }
}