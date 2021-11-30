# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# SDDC network ouputs for use in sddc_cluster module

#subnets
output "internal_subnet_id" {
  description = "OCID of Internal Subnet"
  value       = oci_core_subnet.internal.id
}

