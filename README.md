# tf-gke-cluster
DevOps Course. Terraform Google Kubernetes Engine Cluster 

# Setup
Pay attention to chicken-egg problem of the dependant state bucket.
Read more here [https://dev.to/shihanng/managing-s3-bucket-for-terraform-backend-in-the-same-configuration-2c6c](https://dev.to/shihanng/managing-s3-bucket-for-terraform-backend-in-the-same-configuration-2c6c)

* In order to setup this cluster you need to write a unique bucket name instead of the one provided in the code
* GCS storage must be commented
```
terraform {
  # backend "gcs" {
  #   bucket = "tf-state-430719"
  #   prefix = "terraform/state"
  # }
}
```

* Terraform must be initialized `terraform init`

* Then state storage bucket can be created separately
```
$ terraform plan -target=google_storage_bucket.tf_state -out=/tmp/tfplan
$ terraform apply /tmp/tfplan
```

* Uncomment the state backend config

```
terraform {
  backend "gcs" {
    bucket = "tf-state-430719"
    prefix = "terraform/state"
  }
}
```

* Reinitialize teraform with `terraform init` and write `yes` to migrate the existing state
* Now `terraform plan` and `terraform apply` commands can be used to work with infrastructure resources

# Resources removal

It must be performed in a vice versa way.

* Comment the gcs backend definition
* Run `terraform init -migrate-state` to migrate state to the local file
* Now infrastructure can be removed with `terraform destroy` including with the bucked that have been used as terraform state storage
