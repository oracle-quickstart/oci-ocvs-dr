***Rapid DR Infrastructure Deployment***

# Contents

[Project Overview 1](#project-overview)

[Pre-requisites 2](#pre-requisites)

[Getting Started 4](#getting-started)

[Modules 6](#modules)

[VCN Module 6](#vcn-module)

[SDDC Network and Security Modules 9](#sddc-network-and-security-modules)

[SDDC Cluster Module 13](#sddc-cluster-module)

[Deploy 14](#deploy)

[Advanced Modifications 16](#advanced-modifications)

# Project Overview

Cloud targets are often considered to support DR infrastructure for
several reasons. To start, many companies are operating entire
datacenters housing idle resources with a sole purpose of recovering
Mission Critical workloads in the event of a disaster, often increasing
their infrastructure footprint by \> 50%. This design not only increases
Capital and Operating Expenses, but also introduces an added burden on
teams charged with maintaining additional datacenters, in many casses, 
with disparate hardware.

As companies are venturing into DR, or revamping existing DR designs,
cloud is commonly considered as a viable alternative to costly and
burdensome DR designs. With a Cloud DR endpoint, there’s no longer a
need to pay for unused resources, modern hardware is available on demand
with most ongoing maintenance and lifecycle management handled by the
cloud vendor.

So why are we not seeing a mass exodus from traditional on-prem DR
architectures to the cloud? While not all-inclusive, a few common concerns often
arise in Cloud DR conversations. First, Cloud resources are
not infinite. In the rare event of a mass outage in a populated region, resources
may be consumed quickly, and it is possible resources could be fully
allocated to other consumers. Secondly, many Cloud DR prospects are in
the early phases of their cloud journey and see the learning curve for
cloud adoption too steep, especially if the sole purpose is DR when hands
on experience may only occur every few months. Lastly, a shift to cloud DR 
can introduce the need to rearchitect or
replace existing DR processes, which may be a barrier to Cloud DR
initiatives.

These points are valid and there are pros and cons to weigh as Cloud DR
is evaluated. However, the goal of this project is to mitigate these
areas of concern with a standardized framework for the automated buildout of a DR
environment based on Open Source Terraform. Using IaC to create a known good DR architecture, not only provides flexible 
deployment options to overcome regional resource constraints, but also allows users to update and test their intended DR architectural state as needed. Furthermore, it may
be possible to only incur costs during testing periods or outages, when
DR infrastructure is in use.

**Introduction**

This project leverages Open Source Solutions to provide Infrastructure
as Code (IaC) automation capabilities to architect a robust DR
infrastructure in a logical phased approach. The goal is to provide
flexible architecture options to support a wide array of recovery
methods, from the recovery of workloads to native OCI instances to
entire Software Defined Data Centers (SDDCs) running native VMware
vSphere.

Using IaC techniques allows cloud architectures to be designed in
advance and easily customized as DR needs evolve. Leveraging IaC to
package a standardized architecture provides flexibly in infrastructure
placement allowing for rapid deployment to any region with available
resources.

# Pre-requisites

For the project to function as expected, there are a few items that need
to be in place before proceeding. Please note, there are commonalities
within these steps, and you may encounter overlap.

**Setup OCI Terraform** – the steps outlined in this link cover the
following key tasks. Open this link ->
(<https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm>

**Section - “Before You Begin”**

-   **Establish an Oracle Cloud Infrastructure account** – it’s
    recommended to review the “Setting Up Your Tenancy” section of this
    link to create additional users and compartments to avoid the use of
    the Root Compartment and Administrator Account.

**Section - “1. Prepare”**

-   **Install Terraform** – For the purpose of this exercise it is
    recommended to install Terraform to a local MacOS, Linux, or
    Windows machine. MacOS is not covered well, so commands are outlined
    below.

**MacOS:**

>*/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"*
>
>*brew tap hashicorp/tap*
>
>*brew install hashicorp/tap/terraform*

-   **Create RSA Keys (API Signing)** – Note these are API keys, which
    are different from the RSA keys commonly used for SSH access. SSH
    access keys are addressed in the following section. The typical
    naming conventions for this key set are oci_api_key.pem and
    oci_api_key_public.pem

**Oracle Linux Sample Commands:**

>*mkdir \~/.oci*
>
>*openssl genrsa -out \~/.oci/oci_api_key.pem 2048*
>
>*chmod 600 \~/.oci/oci_api_key.pem*
>
>*openssl rsa -pubout -in \~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem*
>
>*cat \~/.oci/oci_api_key_public.pem*

Add the public key to your user account.

1.  From your user avatar, go to User Settings.

2.  Click API Keys.

3.  Click Add Public Key.

4.  Select Paste Public Keys.

5.  Paste value from previous step, including the lines with BEGIN
    PUBLIC KEY and END PUBLIC KEY

6.  Click Add.

You have now set up the RSA keys to connect to your Oracle Cloud
Infrastructure account.

-   **SSH Keys** – While not covered on this document, SSH access keys
    for secure access to Bastion and ESXi Hosts are required. Follow the
    steps below or follow this link for additional guidance.
    **(<https://docs.oracle.com/en/learn/generate_ssh_keys/index.html#option-5-ssh-keys-for-linux>)**

**Oracle Linux Sample Command:**

>*ssh-keygen*
>
>(press enter to confirm default .ssh directory and file name of id_rsa)
>
>(Create a passphrase, or press enter twice to bypass. Best Practice for
>a production environment would be to use a secure passphrase)
>
>*cd .ssh*
>
>*ls*
>
>(two files, a private key*:* “id_rsa” and a public key “id_rsa.pub”
>should now reside in the directory*)*

-   **Add List Policy** – Required if users outside of the
    Administrators Group require the use of Terraform

-   **Gather Required Information** – Use the template below to store
    your data for later use. If no compartments exist, use the Tenancy
    OCID to designate the root compartment. The Region variable will be
    used directly in our script and can be left out of the exercise. The
    file locations listed are applicable to the key generation process
    outlined above, so there may be no need for altercation of those
    fields.

**Where to find Tenancy and User OCID -**
<https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five>

>tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaarjmezr............"
>
>compartment_ocid="ocid1.compartment.oc1..aaaaaaaak6k332............"
>
>user_ocid="ocid1.user.oc1..aaaaaaaagproszim............"
>
>fingerprint= “12:34:56:78:90:ab……….”
>
>private_key_path="\~/.oci/oci_api_key.pem"
>
>ssh_public_key=$(cat \~/.ssh/id_rsa.pub)
>
>ssh_private_key_path="\~/.ssh/id_rsa"

-   **The additional steps outlined in the linked documentation for this
    section can be skipped. Continue with the remaining requirements
    below.**

****(Optional) Prepare Object Storage**** – Terraform stores
configuration states in plain text format, including sensitive fields
like usernames and passwords. It is a best practice to configure remote
state files to be stored in a secure location. In addition to enhanced
security, using Terraform remote state allows for shared access to
Terraform configurations.

-   Configure Terraform Remote State -
    <https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm>

****Install git** -** <https://git-scm.com/downloads>

# Getting Started 

With the pre-requisites in place, it’s time to download the project
files.

>*git clone https://github.com/oracle-quickstart/oci-ocvs-dr.git dr-vcn*
>
>*cd dr-vcn*
>
>*cp terraform.tfvars.example terraform.tfvars*

**Environment variables**

It’s common to export required authentication values as Environment
Variables to enhance security by avoiding the inclusion of sensitive
values in your code. For testing purposes each Environment Variable may
be individually entered using the export command below. However, each
variable will need to be reloaded anytime the console session is
restarted. For persistence, copy all variables just as they are listed
below to your local .bash_profile, or .bashrc profile and they will be
reloaded as Environment Variables each time the console is launched.
Note, you will need to reload your console after adding to your profile.
To access the Environment Variables currently loaded, type *env* at the
command prompt.

From the directory where the Terraform project was copied, open the file
terraform.tfvars with your preferred text editor

>*cat terraform.tfvars*

Near the top of the file, there is a section labeled Expected
Environment Variables. Copy the fields, minus the hash #, and customize
with your unique values recorded in the pre-requisites section. It’s not
recommended to include these values in the terraform.tfvars file.

Example:

>*export* TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaarjmezr............
>
>*export* TF_VAR_compartment_ocid=ocid1.compartment.oc1..aaaaaaaak6k332............
>
>*export* TF_VAR_user_ocid=ocid1.user.oc1..aaaaaaaagproszim............
>
>*export* TF_VAR_fingerprint=12:34:56:78:90:ab……….
>
>*export* TF_VAR_private_key_path="\~/.oci/oci_api_key.pem"
>
>*export* TF_VAR_ssh_public_key=$(cat \~/.ssh/id_rsa.pub)
>
>*export* TF_VAR_ssh_private_key_path="\~/.ssh/id_rsa"

The completed fields can be individually entered and loaded as system
Environment Variables which will be deleted anytime the console is
closed, or manually added to the .bash_profile or bashrc files and
reloaded each time a new session is launched.

**Oracle Linux Sample Commands:**

>*sudo nano /etc/bashrc*
>
>*source .bashrc*
>
>*env*

The *env* command will load your local Environment variables. Check to
ensure they match what was entered in the profile. If there is a
discrepancy, try adding, or removing, the quotes surrounding the stated
values, e.g., tenancy_ocid, compartment_ocid, user_ocid, fingerprint.
Some Linux distributions handle these entries differently.

Return project directory and edit the terraform.tfvars file to match
your target region

>*nano terraform.tfvars*

Run the following commands

>*terraform init*
>
>*terraform plan*

If our pre-requisites are successful, the *terraform plan* command
should generate a list of objects to be created in the environment. In
the next section we will review the customization options available
within the modules. No resources will be deployed unless the command
“*terraform apply*” is also run, which may incur unexpected costs.

**\*\*\*Caution\*\*\*** If ”*terraform apply*” is initiated and the
sddc_enabled field equals “true” the workflow will deploy an Oracle
Cloud VMware Solution SDDC with a minimum billing fee of, 3x SDDC Hosts
with 8hours of usage. For more info please follow this link
(<https://www.oracle.com/cloud/compute/pricing.html>)

# Modules

This project is divided into various modules that build upon each other to provide flexible options to support the desired end state. A high-level overview featuring the resources created with each model is included below. The customizations for each module are controlled from the terraform.tfvars file located in the project root directory and inputs at supplied to Modules from the main.tf file. For basic functionality, there should be no need to alter any files outside of terraform.tfvars, however, some advanced use cases may require additional customizations to the modules themselves, which will be explored further along in this guide as each module is broken down.

**VCN Modules**

-   VCN - Deploys base Virtual Cloud Network (VCN), Internet Gateway, NAT Gateway, Service Gateway, DRG (optional), Internal Route Table for outbound NAT traffic and local communication. Public module located here (<https://registry.terraform.io/modules/oracle-terraform-modules/vcn/oci/3.0.0>)

-   VCN Networks -  Creates Internal /24 Subnet and Security List connected to the Internal Route Table

-   Bastion – Creates External /24 Subnet and Security List and Bastion Route Table with outbound connectivity through the Internet Gateway. Public module located here (<https://github.com/oracle-terraform-modules/terraform-oci-bastion/releases/tag/v3.0.0>)

-   Instance – Creates Windows Instance for Jumpbox access on the Internal Network. Public module located here (<https://github.com/oracle-terraform-modules/terraform-oci-compute-instance/releases/tag/v2.2.0>)

**SDDC Modules**

-   SDDC Networks – Provisions networks required to support SDDC Cluster
    and a Route Table for SDDC communications

-   SDDC Security – Creates Security Lists and Network Security groups
    for SDDC networks, with an option for hardened networks

-   SDDC Cluster – Instantiates SDDC Cluster consisting of vSphere Ent+,
    VSAN and NSX along with one NSX workload segment

## VCN Module

**Overview**

As the name suggest, the modules combined create a Virtual Cloud Network (VCN) and the common resources required for base functionality. It’s also possible to apply the entire Terraform plan with only the VCN modules activated. The additional modules are controlled with feature flags within the terraform.tfvars file. 

**Architecture**

By default, the VNC Module deploys a common cloud footprint as described
below.

![VCN Diagram](/images/vcn.png)

**VCN Resources**

Virtual Cloud Network (VCN) - A virtual, private network that closely
resembles a traditional network, with firewall rules and specific types
of communication gateways.

Internet Gateway – Virtual Router for direct internet access.

NAT Gateway – Virtual Router to provide cloud resources access to the
internet without exposing those resources to incoming internet
connection.

Service Gateway - Virtual Router to provide a path for private network
traffic to Oracle Cloud Services (examples: Oracle Cloud Infrastructure
Object Storage and Autonomous Database).

Dynamic Routing Gateway (optional) - A virtual router that provides a path for private network traffic between your VCN and your existing network. You use it with other Networking Service components to create an IPSec VPN or a connection that uses Oracle Cloud Infrastructure FastConnect.

**Network Resources**

Internal Subnet – Regional Private Subnet limited to private IPs and outbound Internet connectivity through the NAT Gateway. Default /24 CIDR block assigned from VCN CIDR.

Bastion Subnet – Regional Public Subnet that allows for direct internet connectivity using public IPs and Internet Gateway. Default /24 CIDR block assigned from VCN CIDR.

Internal Route Table – Route table assigned to private subnet containing default route to NAT Gateway for internet access and route to OCI Services through Service Gateway.

Bastion Route Table – Route Table assigned to Bastion Subnet with default route to Internet Gateway.

Security Lists - A security list acts as a virtual firewall for an instance, with ingress and egress rules that specify the types of traffic allowed in and out. Security lists are configured at the subnet level and enforced at the VNIC level, which means that all VNICs in each subnet are subject to the same set of security lists. The security lists apply to a given VNIC whether it's communicating with another instance in the VCN or a host outside the VCN. The Security Lists created by the VCN Module are outlined below:


-	Global Security List – Security list designed to allow all egress traffic and limit ingress traffic to ICMP only.
 
-	Bastion Security List – Security list designed for external access control. By default, it is limited to accept ingress SSH and RDP traffic only and applied to the external subnet. 

-	Internal Security List – Security List designed for internal access control. By default, all traffic from VCN and Workload CIDR blocks are allowed. Note – Workload CIDR value is located within the SDDC Cluster Details section of Terraform.tfvars file. 

-	Default Security List – Default resource created with VCN. Not in use. 

**Compute Resources**

Bastion Host – Bastions let authorized users connect from specific IP
addresses to target resources using Secure Shell (SSH) sessions. When
connected, users can interact with the target resource by using any
software or protocol supported by SSH. For example, you can use the
Remote Desktop Protocol (RDP) to connect to a Windows host, or use
Oracle Net Services to connect to a database. More information
(<https://docs.oracle.com/en-us/iaas/Content/Resources/Assets/whitepapers/bastion-hosts.pdf>)

Default Bastion Configuration:

Shape - VM.Standard.E3.Flex, 1 OCPUs, 4GB RAM

OS – Oracle-Linux

Windows Server – Jump host for internal access to VCN resources
primarily accessed by creating an SHH tunnel through Bastian Host. Upon
completion of VCN Module workflow, a Linux SSH tunnel command is
provided. More options are available and outlined in the Bastian
whitepaper referenced above.

Default Windows Configuration:

Shape - VM.Standard.E3.Flex, 2 OCPUs, 32GB RAM

OS – Windows-Server-2019-Standard-Edition-VM-E3-2021.02.13-0

**Inputs**

The VCN Module includes the following customizable input variables in
the Terraform.tfvars file.

region – This field indicates the geographical location for the
placement of the VCN. Some regions provide added redundancy by locating
multiple data centers within the Region referred to as Availability
Domains (AD). Given compute resources are often collocated within the
same AD and not all regions include multiple ADs, a default has been is
set so AD1 is always selected.

vcn_name – (Updateable) - A user-friendly name applied to the VCN
resources. It does not have to be unique, and it's changeable. Avoid
entering confidential information.

vcn_dns_label - A DNS label for the VCN, used in conjunction with the
VNIC's hostname and subnet's DNS label to form a fully qualified domain
name (FQDN) for each VNIC within this subnet (for
example, bminstance-1.subnet123.vcn1.oraclevcn.com). Not required to be
unique, but it's a best practice to set unique DNS labels for VCNs in
your tenancy. Must be an alphanumeric string that begins with a letter.
The value cannot be changed.

vcn_cidr – The CIDR block assign to the VCN in which all networks will
be derived. The minimum CIDR size supported is /20 and the module are
designed to only support a /20 entry. The /20 network will be halved
with the bottom range /21 supporting native VCN resources and the upper
/21 range assigned to the SDDC where it is split into multiple SDDC
supporting networks. The value should not overlap with your on-premise
networks if any site pairing is required. The value cannot be changed.

Label_prefix - (optional) If any value other than "none", the prefix
value is added to naming of all resources. This field can be useful in
situations when naming conventions match between sites and there is a
need to easily distinguish each site. The value cannot be changed

Freeform_tags - (Updatable) Free-form tags that are applied to all
resources deployed by Terraform. Each tag is a simple key-value pair
that can be customized to any key-value pair.

**\*\*\*Caution\*\*\*** If ”*terraform apply*” is initiated and the
sddc_enabled field equals “true” the workflow will deploy an Oracle
Cloud VMware Solution SDDC with a minimum billing fee of, 3x SDDC Hosts
with 8hours of usage. For more info please follow this link
(<https://www.oracle.com/cloud/compute/pricing.html>)

## SDDC Network and Security Modules

**Overview**

The SDDC Network and Security Modules create the networks required to
support an OCVS VMware SDDC. This capability is offered separately from
the SDDC Cluster module to allow for network customization and testing
without the need for cluster deployment to allow for routine testing of
networking without incurring the added costs of an SDDC.

**Architecture**

The SDDC Network and Security Module builds upon the VCN Module
architecture by including the additional cloud components as described
below.

![Network Diagram](/images/network.png)

**Network Resources**

SDDC-Provisioning Regional Subnet – Network for ESXi Host management.

NSX Edge VTEP Regional VLAN - Used for data plane traffic between the ESXi host and NSX Edge. 

NSX VTEP Regional VLAN - Used for data plane traffic between ESXi hosts.

vMotion Regional VLAN - Used for vMotion (VMware migration tool) management and workload.

VSAN Regional VLAN - Used for VSAN (VMware storage) data traffic.

Replication Regional VLAN - Used for the vSphere Replication engine. (VMware version 7.x only)

Provisioning Regional VLAN - Used for virtual machine cold migration, cloning, and snapshot migration.

NSX Edge Uplink 1 Regional VLAN - Uplink used for communication between the VMware SDDC and Oracle Cloud Infrastructure.

NSX Edge Uplink 2 Regional VLAN- Reserved for future use to deploy public-facing applications on the VMware SDDC.

HCX Regional VLAN (optional) - Used for HCX traffic. Create this VLAN if you plan to enable HCX when you provision the SDDC.

vSphere Regional VLAN - Used for management of the SDDC components (ESXi, vCenter, NSX-T, and NSX Edge).

SDDC Internal Route Table (sddc-internal) - Route table assigned to select SDDC networks with a single default NAT Gateway route. 

**Security Resources**

SDDC Internal Security List (sddc-internal) – Security list assigned
to SDDC Provisioning Subnet.

Network security groups (NSGs) act as a virtual firewall for your
Compute instances and other kinds of resources. An NSG consists of a set
of ingress and egress security rules that apply only to a set of VNICs
of your choice in a single VCN (for example: all the Compute instances
that act as web servers in the web tier of a multi-tier application in
your VCN). The following NSGs are created:

NSX-Edge-VTEP-NSG – NSG assigned to vNICs on NSX Edge VTEP VLAN

NSX-VTEP-NSG – NSG – NSG assigned to vNICs NSX VTEP VLAN

vMotion-NSG - NSG assigned to vNICs on vMotion VLAN

VSAN-NSG - NSG assigned to vNICs on VSAN VLAN

Replication-NSG - NSG assigned to vNICs on Replication VLAN

Provisioning-NSG - NSG assigned to vNICs on Provisioning VLAN

NSX-Edge-Uplink-NSG - NSG assigned to vNICs on NSX Edge Uplink 1&2 VLANs

HCX-NSG (optional) - NSG assigned to vNICs on HCX VLAN

vSphere-NSG - NSG assigned to vNICs on vSphere VLAN

For additional information regarding OCVS NSG Security, please visit -
<https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm>

**Inputs**

The SDDC Network and Security Modules include the following customizable
input variables in the Terraform.tfvars file.

sddc_network_enabled - dictates whether the SDDC Network resources will
be deployed. If “true”, networks will be included as part of the
workflow, otherwise only the VCN Module will be deployed.

sddc_network_hardened – dictates the level of security applied to SDDC
Network Security Groups. The following values are available:

true – All SDDC NSGs will include the default security rules outlined in
the OCVS documentation -
<https://docs.oracle.com/en-us/iaas/Content/VMware/Reference/ocvssecurityrules.htm>

false –SDDC NSGs below will only include the following less restrictive
stateful rules:

![NSG Diagram](/images/nsg.png)

**\*\*\*Caution\*\*\*** If ”*terraform apply*” is initiated and the
sddc_enabled field equals “true” the workflow will deploy an Oracle
Cloud VMware Solution SDDC with a minimum billing fee of, 3x SDDC Hosts
with 8hours of usage. For more info please follow this link
(<https://www.oracle.com/cloud/compute/pricing.html>)

## 

## SDDC Cluster Module

**Overview**

The SDDC Cluster Module uses the infrastructure created in the previous
modules as a framework to support an Oracle Cloud VMware Solution (OCVS)
SDDC. Cluster buildout is offered separately from the previous modules
to allow for periodic design updates and testing without the need for
cluster deployment.

**Architecture**

The SDDC Cluster Module builds upon the architecture created in the
previous modules by including the additional cloud components as
described below.

![Cluster Diagram](/images/cluster.png)

**Compute Resources**

Oracle Cloud VMware Solution SDDC – VMware cluster consisting of vSphere
Ent+, VSAN, and NSX-T installed on a minimum of 3 Bare Metal Instances

Bare Metal Instances – Minimum of 3 BM.DenseIO2.52 Compute instances.
Each instance includes 52 OCPUs, 768GB RAM and \~51TB RAW NVMe storage

SDDC Management Appliances – Virtual appliances required for SDDC
operations.

For additional information regarding Oracle Cloud VMware Solution,
please visit -
<https://docs.oracle.com/en-us/iaas/Content/VMware/Concepts/ocvsoverview.htm>

**Inputs**

The SDDC Cluster Module includes the following customizable input
variables in the Terraform.tfvars file.

sddc_enabled - dictates whether the SDDC resources will be deployed. If
“true”, an OCVS SDDC will be deployed on a minimum of 3 Bare Metal
Instances.

sddc_display_name – friendly name assigned to OCVS SDDC

esxi_hosts_count – quantity of Bare Metal Instances deployed for cluster
resources. Minimum value 3, recommended maximum 16. ****\*\*\*
Important\*\*\***** changing host count following the initial SDDC
deployment will result in deletion and recreation of entire cluster
including data.

vmware_software_version – version of VMmare SDDC Software deployed to
cluster. Example vSphere 6.x, 7.x. ****\*\*\* Important\*\*\*****
Changing SW Version following the initial SDDC deployment will result in
deletion and recreation of entire cluster including data.

initial_sku - term length of initial deployment

is_hcx_enabled – dictates whether HCX Appliance, Networks and Security
Rules are deployed

workload_network_cidr – CIDR range of initial NSX-T segment. Additional
segments will need to be manually created at this time. Additional
modules are road mapped for SDDC Segment creation.

For additional information regarding Oracle Cloud VMware Solution,
please visit -
<https://docs.oracle.com/en-us/iaas/Content/VMware/Concepts/ocvsoverview.htm>

# Deploy

The VCN Module is the Base Module for this project and runs by default
without an option to disable the workflow. The additional modules have
flags that dictate whether they are included in the workflow. It’s
recommended to review the inputs outlined in the terraform.tfvars file
for accuracy before initiating any workflows.

-   SDDC Network and Security Modules are activated when the
    terraform.tfvars sddc_network_enabeled value equals “true” and the
    level of security is dictated by the value of sddc_network_hardened.

-   SDDC Cluster Module is activated when the terraform.tfvars
    sddc_network_enabeled and sddc_enabled values both equal “true”.

**\*\*\*IMPORTANT NOTE\*\*\*** If the sddc_enabled field equals “true”
the workflow will deploy an Oracle Cloud VMware Solution SDDC with a
minimum billing fee of, 3x SDDC Hosts with 8hours of usage. For more
info please follow this link
(<https://www.oracle.com/cloud/compute/pricing.html>)

After reviewing the terraform.tfvars file for accuracy, proceed with the
with the following commands from the root directory of the project.

>*terraform init*
>
>*terraform plan*

**Important** - Review the output from the terraform plan command for
accuracy. If acceptable, proceed with issuing the following command to
deploy the resources outlined in the output.

>*terraform apply*

Once complete, an output section will be displayed with a summary of the
deployment. This project is meant to be iterative with each module
building on the next without the need redeploy the entire infrastructure
as each module is introduced. As changes are made to the
terraform.tfvars file, terraform init/plan can be reissued and a summary
of changes to the existing deployment will be outline in the plan
section.

Changes are designated with prefixes ( \~ , +, - , -/+) appended to each
resource to designate the action that will be taken to implement the new
infrastructure. It’s possible a minor change to a filed ****could
result in the forced destruction**** of the original resource before
it is recreated to reflect the new configuration. Please review the
links below to learn more.

Learn more about Terraform provisioning commands -
<https://www.terraform.io/docs/cli/run/index.html>

Learn how Terraform handles changes to deployed infrastructure -

<https://learn.hashicorp.com/tutorials/terraform/oci-change?in=terraform/oci-get-started>

Understand what input values for Terraform Deployed resources are
updateable, or may trigger a destroy and replace action -
<https://registry.terraform.io/providers/hashicorp/oci/latest/docs>

# Advanced Modifications

**Modify Route Tables**

Oracle Cloud VMware Solution deploys a pair of NSX Edge node appliances that act a security boundary between the SDDC and VCN. For external traffic to properly route to the NSX-T segments within the SDDC, a route must be created with a destination of the NSX VIP. 

The Oracle Cloud Terraform provider has a limitation that prevents the update of route tables after initial deployment. Fortunately, there is a publicly available utility that provides a workaround. 

**Note** - Oracle QuickStart policy does not allow for the usage of Python within a QuickStart Project, however, the project can be manually updated by the end user. This section outlines the steps needed to update an OCI Route Table Post deployment using a simple utility, ORTU - https://pypi.org/project/ortu/

ORTU requires Python as a pre-requisite.

****Install OCI CLI / Python**** – Two options, a QuickStart and
Manual installation are available here.
<https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm>
. Be sure to complete the final step near the bottom of the page
“Setting up the config file”, by running *oci setup config* command. The
entries needed were recorded in the Setup OCI Terraform section of this
guide. When asked for the location of the API signing Key, it’s listed
as the private_key_path above if you followed the guidance provided in
this guide.

ORTU is triggered using a Terraform null resource provisioner. The inputs required for routing to the initial NSX-T segments are already included in the project, along with sample code located in the modules directory modules/sddc/cluster/cluster.tf . If additional segments are added post deployment, the route table and security rules will require additonal modification. 
