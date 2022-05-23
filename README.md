# Cloudfront CDN for Static Website

This zip file contains the Terraform module and an example deployment of the module. 

## How to Use
To use the example in this zip file, navigate to the example directory, and run the following steps:

Edit the main.tf file and input the variables that suit the deployment scenario.
To initialise the Terraform project, run:
```sh
terraform init
```
To view a manifest of the resources that are about to get deployed, run:
```sh
terraform plan
```
To deploy the resources in your environment, be sure to add AWS credentials in your local config (or environment variables) and run:
```sh
terraform apply
```

Copy the index.html file into the 'content' bucket created in the previous step.
Open up a browser, and go to https://\<yourdomain\</index.html, and the CDN should respond with the uploaded index.html file. Logs can be seen of this event in the 'logs' bucket.

Finally, to delete the resources deployed in the previous step, run the following:
```sh
terraform destroy
```
