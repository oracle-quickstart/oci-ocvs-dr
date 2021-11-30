// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "bastion_ssh_command" {
  value = "ssh -i ${var.ssh_private_key_path} opc@${module.bastion.bastion_public_ip}"
}


output "local_jumpbox_tunnel" {
  value = "ssh -i ${var.ssh_private_key_path} opc@${module.bastion.bastion_public_ip} -L 3381:${module.instance.private_ip[0]}:3389"
}


/*

# If enabled, current OCVS options will be dislayed in outputs

output "supported_sddc_skus" {
  value = data.oci_ocvp_supported_skus.supported_skus[*].items
}

output "sddc_sowtware_versions" {
  value = data.oci_ocvp_supported_vmware_software_versions.supported_vmware_software_versions[*].items
}
*/

/*
# If enabled, sensitive information will be stored in state file.

output "vcenter_username" {
  value = module.sddc_cluster.vcenter_username
}

output "vcenter_initial_password" {
  value = module.sddc_cluster.vcenter_initial_password
}

*/


