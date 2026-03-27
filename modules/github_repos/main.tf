locals {
  environments = ["test/plan", "test/apply", "prod/plan", "prod/apply"]

  repo_environments = {
    for pair in setproduct(keys(var.repo_data_map), local.environments) :
    "${pair[0]}/${pair[1]}" => {
      repo        = pair[0]
      environment = pair[1]
      is_prod     = startswith(pair[1], "prod")
    }
  }
}

data "github_team" "prod_reviewers" {
  for_each = {
    for k, v in var.repo_data_map :
    k => v if can(v.prod_reviewer_team)
  }
  slug = each.value.prod_reviewer_team
}

resource "github_repository" "repos" {
  for_each = var.repo_data_map

  name        = each.value.name
  description = lookup(each.value, "description", "")
  visibility  = "private"

  has_issues             = lookup(each.value, "has_issues", true)
  has_wiki               = lookup(each.value, "has_wiki", true)
  has_projects           = lookup(each.value, "has_projects", true)

  allow_squash_merge = lookup(each.value, "allow_squash_merge", true)
  allow_merge_commit = lookup(each.value, "allow_merge_commit", false)
  allow_rebase_merge = lookup(each.value, "allow_rebase_merge", true)
}

resource "github_repository_environment" "environments" {
  for_each = local.repo_environments

  repository  = github_repository.repos[each.value.repo].name
  environment = each.value.environment

  dynamic "reviewers" {
    for_each = each.value.is_prod && can(data.github_team.prod_reviewers[each.value.repo]) ? [1] : []
    content {
      teams = [data.github_team.prod_reviewers[each.value.repo].id]
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.is_prod ? [1] : []
    content {
      protected_branches     = true
      custom_branch_policies = false
    }
  }

  depends_on = [github_repository.repos]
}