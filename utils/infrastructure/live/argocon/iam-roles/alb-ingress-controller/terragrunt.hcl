dependency "eks" {
  config_path = "../../eks"
}

inputs = {
  ingress-controller-service-accounts = ["system:serviceaccount:aws-controllers:ingress-controller-aws-load-balancer-controller"]
  oidc_provider_arn                   = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url                   = dependency.eks.outputs.cluster_oidc_issuer_url
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/iam-roles/ingress-controller"

  extra_arguments "common _vars" {
    commands = get_terraform_commands_that_need_vars()
    required_var_files = [
      find_in_parent_folders("tags.tfvars")
    ]
  }
}