# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

#########################################
# Security List / Network Security Groups
#########################################

#OCVS bset practice - https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm

locals {
  any_port                 = 0
  ssh_port                 = 22
  dns_port                 = 53
  http_port                = 80
  ntp_port                 = 123
  cim_port                 = 123
  https_port               = 443
  vcenter_agent_port       = 902
  hcx_cold_port            = 902
  vcenter_port             = 903
  nsx_msg_min_port         = 1234
  nsx_msg_max_port         = 1235
  rdt_port                 = 2233
  nestdb_port              = 2480
  rdp_port                 = 3389
  iscsi_port               = 3260
  
  bfd_min_port             = 3784
  bfd_max_port             = 3785
  hcx_wan_port             = 4500
  systemd_port             = 5355
  vami_port                = 5480
  nsx_agent_port           = 5555
  amqp_port                = 5671
  rfb_min_port             = 5900
  rfb_max_port             = 5964
  cim_min_port             = 5988
  cim_max_port             = 5989
  geneve_port              = 6081
  esxi_dump_port           = 6666
  nsx_edge_port            = 6666
  nsx_dlr_port             = 6999
  vmotion_port             = 8000
  http_alt_port            = 8080
  ft_min_port              = 8100
  vsan_health_port         = 8006
  vsan_health_max_port    = 8010
  ft_max_port              = 8300
  dvs_min_port             = 8301
  dvs_max_port             = 8302
  web_svc_port             = 8889
  dist_ds_port             = 9000
  iofilter_port            = 9080
  vsphere_web_port         = 9090
  rest_api_port            = 9443
  unicast_agent_port       = 12321
  vsan_cluster_min_port    = 12345
  vsan_cluster_max_port    = 23451
  license_min_port         = 27000
  license_max_port         = 27010
  hcx_bulk_port            = 31031
  initial_replication_port = 31031
  ongoing_replication_port = 44046
  nsx_edge_ha_port         = 50263

  any_protocol  = "all"
  icmp_protocol = "1"
  tcp_protocol  = "6"
  udp_protocol  = "17"
  rdp_protocol  = "27"

  anywhere      = "0.0.0.0/0"

  sddc_cidr     = cidrsubnet(var.vcn_cidr, 1, 1)
}