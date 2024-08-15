module "gke_cluster" {
  source         = "git::https://github.com/suhovius/tf-google-gke-cluster.git"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 2
}

terraform {
  backend "gcs" {
    bucket = "tf-gke-state-430719"
    prefix = "terraform/state"
  }
}
  