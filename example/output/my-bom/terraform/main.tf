module "ibm-vpc" {
  source = "cloud-native-toolkit/vpc/ibm"
  version = "1.16.0"

  address_prefix_count = var.ibm-vpc_address_prefix_count
  address_prefixes = var.ibm-vpc_address_prefixes == null ? null : jsondecode(var.ibm-vpc_address_prefixes)
  base_security_group_name = var.ibm-vpc_base_security_group_name
  internal_cidr = var.ibm-vpc_internal_cidr
  name = var.ibm-vpc_name
  name_prefix = var.name_prefix
  provision = var.ibm-vpc_provision
  region = var.region
  resource_group_name = module.resource_group.name
  tags = var.ibm-vpc_tags == null ? null : jsondecode(var.ibm-vpc_tags)
}
module "ibm-vpc-subnets" {
  source = "cloud-native-toolkit/vpc-subnets/ibm"
  version = "1.13.2"

  _count = var.ibm-vpc-subnets__count
  acl_rules = var.ibm-vpc-subnets_acl_rules == null ? null : jsondecode(var.ibm-vpc-subnets_acl_rules)
  gateways = var.ibm-vpc-subnets_gateways == null ? null : jsondecode(var.ibm-vpc-subnets_gateways)
  ipv4_address_count = var.ibm-vpc-subnets_ipv4_address_count
  ipv4_cidr_blocks = var.ibm-vpc-subnets_ipv4_cidr_blocks == null ? null : jsondecode(var.ibm-vpc-subnets_ipv4_cidr_blocks)
  label = var.ibm-vpc-subnets_label
  provision = var.ibm-vpc-subnets_provision
  region = var.region
  resource_group_name = module.resource_group.name
  tags = var.ibm-vpc-subnets_tags == null ? null : jsondecode(var.ibm-vpc-subnets_tags)
  vpc_name = module.ibm-vpc.name
  zone_offset = var.ibm-vpc-subnets_zone_offset
}
module "resource_group" {
  source = "cloud-native-toolkit/resource-group/ibm"
  version = "3.2.16"

  ibmcloud_api_key = var.ibmcloud_api_key
  resource_group_name = var.resource_group_name
  sync = var.resource_group_sync
}
