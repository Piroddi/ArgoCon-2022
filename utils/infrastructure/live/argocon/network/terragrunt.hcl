inputs = {
  cidr_range      = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.0.0/18", "10.0.64.0/18", "10.0.128.0/18"]
  public_subnets  = ["10.0.192.0/20", "10.0.208.0/20", "10.0.224.0/20"]
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/network"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    optional_var_files = [
      find_in_parent_folders("tags.tfvars")
    ]
  }
}