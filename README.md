# Azure-Hybrid-Firewall-using-Terraform
This repository contains Terraform code for deploying an Azure Firewall hybrid network architecture. The setup includes Virtual Machines, Virtual Network Gateway, VNet-to-VNet connections, VNet peering, subnets, network security groups, firewall network interfaces, IP addresses, and route tables.

Architecture Overview
The architecture uses a hybrid setup with Azure Firewall, VNet-to-VNet connections, and other essential components. 
The Terraform code defines and provisions the necessary resources to build the architecture.

Terraform Files Structure

├── main.tf

├── variables.tf

├── terraform.tfvars

└── README.md

main.tf
The main.tf file contains the core resources that define the architecture:

Virtual Machines: Deploys VMs for different purposes such as management, connectivity, etc.
Virtual Network Gateway: Sets up the VPN gateway for secure communications between networks.
VNet-to-VNet Connections: Configures the connections between virtual networks.
VNet Peering: Establishes peering relationships between VNets.
Virtual Networks and Subnets: Creates the virtual networks and subnets within Azure.
Network Security Groups (NSGs): Configures NSGs for controlling traffic between VMs and other resources.
Firewall: Deploys the Azure Firewall to secure the network.
Network Interface Cards (NICs): Creates NICs for VMs and firewall.
IP Addresses: Assigns IP addresses to VMs and interfaces.
Route Tables: Configures route tables to manage traffic routing between VNets.

variables.tf
The variables.tf file defines all the variables that are used in the deployment:

Defines input parameters such as the names of resources, network configurations, and security settings.
Ensures flexibility and reusability of the Terraform code by using variables for key settings like IP address ranges, resource names, and more.

terraform.tfvars
The terraform.tfvars file initializes the values of the variables defined in variables.tf. This is where you provide values for variables such as:

Resource names: Define names for Vmname, sku, configure ranges for private IPs and public IPs and other resources.
IP Addresses: Configure ranges for private IPs and public IPs where necessary.


![image](https://github.com/user-attachments/assets/9b4fe695-b554-4c7a-afef-e1f3737b956f)


