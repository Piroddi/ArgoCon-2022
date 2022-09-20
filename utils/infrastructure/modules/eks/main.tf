data "aws_caller_identity" "current" {}

locals {

  tags = merge(
    var.tags,
    {
      cluster_name = "ArgoCon-2022"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  ################################################################################
  # Cluster
  ################################################################################
  cluster_name                    = "ArgoCon-2022"
  cluster_version                 = "1.23"
  cluster_enabled_log_types       = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_kms_key                  = true
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true
  kms_key_enable_default_policy   = true
  cluster_encryption_config = [
    {
      resources = ["secrets"]
    }
  ]

  subnet_ids = var.private_subnets

  ################################################################################
  # Cluster Security Group
  ################################################################################

  vpc_id = var.vpc_id

  create_cluster_security_group          = true
  cluster_security_group_use_name_prefix = false
  cluster_security_group_name            = "argocon2022-cluster-sg"
  cluster_security_group_description     = "Security group for argocon2022-cluster-sg cluster"

  ################################################################################
  # Node Security Group
  ################################################################################
  node_security_group_use_name_prefix = false

  node_security_group_additional_rules = {
    ingress_ssh = {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      type        = "ingress"
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }
  ################################################################################
  # IRSA
  ################################################################################
  enable_irsa = true

  ################################################################################
  # Cluster IAM Role
  ################################################################################

  create_iam_role          = true
  iam_role_use_name_prefix = false
  iam_role_name            = "argocon2022-cluster-role"

  ################################################################################
  # EKS Managed Node Group
  ################################################################################
  create_node_security_group = true
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium", "t3.large"]

    attach_cluster_primary_security_group = false
    use_name_prefix                       = false
    create_launch_template                = true
    create_security_group                 = false
  }


  eks_managed_node_groups = {
    argocon = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "ArgoCon-2022"
        GithubRepo  = "ArgoCon-2022"
      }
    }
  }
  ################################################################################
  # aws-auth configmap
  ################################################################################
  manage_aws_auth_configmap = false

  cluster_tags = local.tags

}