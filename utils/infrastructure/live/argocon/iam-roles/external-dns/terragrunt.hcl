dependency "eks" {
  config_path = "../../eks"
}

inputs = {
  external-dns-service-account = ["system:serviceaccount:aws-controllers:external-dns"]
  oidc_provider_arn            = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url            = dependency.eks.outputs.cluster_oidc_issuer_url
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/iam-roles/external-dns"

  extra_arguments "common _vars" {
    commands = get_terraform_commands_that_need_vars()
    required_var_files = [
      find_in_parent_folders("tags.tfvars")
    ]
  }
}