variable "region" {  
  type = string  
  default = "ap-southeast-2"  
  description = "Region to deploy into"
}

variable "environment" {
  type = string
  description = "Deployment environment (dev, prod, etc)"
}

variable "bucket_name" {
    type = string
    description = "Name of the s3 bucket serving as CDN origin"  
}

variable "domain" {
    type = string
    description = "Domain to deploy into hosted zone"
}

variable "price_class" {
    type = string
    description = "Price class for the Cloudfront distro"  
}

variable "hosted_zone_name" {
    type = string
    description = "Hosted zone name"
}

variable "cors_origin" {
    type = string
    description = "Origin that cors is enabled for"
}
