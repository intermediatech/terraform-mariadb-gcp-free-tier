# GCP Free tier - MariaDB
This terraform will create a GCE instance with MariaDB installed, using the GCP free tier resources.
>_Author: Vishnu Pradeep_  
>_Contact me at [email](mailto:intermedia.vishnu@gmail.com)_

## Requirements
1. Service account key (json file)  
This can be obtained by following the steps mentioned in [this document](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
2. Terraform [Installation document](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. Generate key file to be added to instance [Link](https://linuxhint.com/generate-ssh-keys-on-linux/)

## Steps
1. Modify the terraform.tfvars to suit your project
2. Modify password in init.sh. This will be the root password
