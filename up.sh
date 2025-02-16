#!/bin/sh
set -eu
./update-tfvars.sh
terraform init -input=false
terraform plan -input=false
terraform apply -input=false -auto-approve
./provision.sh
