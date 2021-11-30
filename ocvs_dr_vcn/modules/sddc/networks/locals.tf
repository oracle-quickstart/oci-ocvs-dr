# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/


locals {
  anywhere      = "0.0.0.0/0"

  sddc_cidr     = cidrsubnet(var.vcn_cidr, 1, 1)

}