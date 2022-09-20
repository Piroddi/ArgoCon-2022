dependency "vpc" {
  config_path = "../network"
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc_id
  vpc_cidr        = dependency.vpc.outputs.vpc_cidr_block
  private_subnets = dependency.vpc.outputs.private_subnets
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    optional_var_files = [
      find_in_parent_folders("tags.tfvars")
    ]
  }
}