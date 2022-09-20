module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ArgoCon"
  cidr = var.cidr_range

  azs                          = var.azs
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  create_database_subnet_group = false

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name                                 = "ArgoCon-public"
    "kubernetes.io/cluster/ArgoCon-2022" = "owned"
    "kubernetes.io/role/elb"             = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags

  enable_dns_hostnames = true
  enable_dns_support   = true

  vpc_tags = var.tags
}