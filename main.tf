/*
It does not look very practical to create terraform state bucket from the terraform
As it breaks the state in the intial setup, brings issues with terraform providers compatibility
and moreover when resources are deleted, bucket is also deleted and so terraform fails to save state
of the deleted resources, as there is no ways to enforoce the order of resources removal
Below you can see the experiments of such bucket creation and import in the commeted lines below
*/

/*
import {
  id = "cluster-test-430719/tf-state-430719"
  to = google_storage_bucket.tf_state
}
*/

/*
resource "google_storage_bucket" "tf_state" {
  name          = "tf-state-430719"
  project       = var.GOOGLE_PROJECT
  storage_class = "STANDARD"
  location      = var.TF_STATE_BUCKET_LOCATION
  force_destroy = true

  public_access_prevention = "enforced"

  versioning {
    enabled = true
  }
}
*/

module "github_repository" {
  source                   = "git::https://github.com/suhovius/tf-github-repository.git"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux0"
}

module "gke_cluster" {
  source         = "git::https://github.com/suhovius/tf-google-gke-cluster.git"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}

module "flux_bootstrap" {
  source            = "git::https://github.com/suhovius/tf-fluxcd-flux-bootstrap.git"
  github_repository = module.github_repository.full_name
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.gke_cluster.kubeconfig
}

module "tls_private_key" {
  source    = "git::github.com/suhovius/tf-hashicorp-tls-keys.git"
  algorithm = "RSA"
}

terraform {
  backend "gcs" {
    bucket = "tf-state-430719"
    prefix = "terraform/state"
  }
}