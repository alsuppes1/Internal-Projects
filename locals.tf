locals {
    environment_data = jsondecode(file("${path.cwd}/environment.json"))

    # landing_zone_data_dir is the directory containing the YAML files for the landing zones.
    repo_data_dir = "${path.cwd}/repos"

    # landing_zone_files is the list of landing zone YAML files to be processed
    repo_files = fileset(local.repo_data_dir, "*.yaml")

    # landing_zone_data_map is the decoded YAML data stored in a map
  repo_data_map = {
    for f in local.repo_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${local.repo_data_dir}/${f}"))
  }

  environment            = basename(path.cwd)
  github_org = local.environment_data.githubOrg
}