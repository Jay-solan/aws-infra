# aws-infra

## terraform commands to bring-up the infrastructure

* init the terraform
``` 
cd ./sandbox
terraform init
```
* plan the code
 ```
 terraform plan -out plan
```
* apply the infrastructure
```
terraform apply "plan"
```
this will bring up the new infrastructure

create a new folder similar to sandbox for another tiers and run the same commands to bring up the new infrastructure.
