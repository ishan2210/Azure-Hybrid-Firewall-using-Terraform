# Azure-Hybrid-Firewall-using-Terraform
Deploy and configure Azure Firewall in a hybrid network by using Terraform.

When you connect your on-premises network to an Azure virtual network to create a hybrid network, the ability to control access to your Azure network resources is an important part of an overall security plan.

You can use Azure Firewall to control network access in a hybrid network by using rules that define allowed and denied network traffic.

VNet-Hub: The firewall is in this virtual network.

VNet-Spoke: The spoke virtual network represents the workload located on Azure.

VNet-Onprem: The on-premises virtual network represents an on-premises network. In an actual deployment, you can connect to it by using either a virtual private network (VPN) connection or an Azure ExpressRoute connection. For simplicity, this article uses a VPN gateway connection, and an Azure-located virtual network represents an on-premises network.

![image](https://github.com/user-attachments/assets/9b4fe695-b554-4c7a-afef-e1f3737b956f)


