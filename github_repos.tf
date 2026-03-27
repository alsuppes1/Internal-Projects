module "github_repos" {
  source = "./modules/github_repos"

  environment = local.environment
  github_owner = local.github_org
  repo_data_map = local.repo_data_map
}