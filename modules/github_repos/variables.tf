variable "environment" {
    type = string
    description = "Evironment for the repo"
}

variable "github_owner" {
    type = string
    description = "Owner of the GitHub organizatiom"
}

variable "repo_data_map" {
    type = any
    description = "Where the files to create the repos live"
}