provider "aws" {
  region = "ap-southeast-2"
}

module "salek_cdn" {
  source = "../cdn-static-site"
  environment = "dev"
  bucket_name = "salek-cdn"
  domain = "<input url for the cdk distro here, for example: cdn.dev.mydomain.com>"
  hosted_zone_name = "<input hosted zone name here, for example: dev.mydomain.com>"
  price_class = "<input price class, for example: PriceClass_200>"
  cors_origin = "<input origin to enable cors for>"
  region = "ap-southeast-2"
}