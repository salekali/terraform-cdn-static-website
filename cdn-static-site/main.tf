# BUCKET THAT HOSTS CONTENT
# ---------------=----------

resource "aws_s3_bucket" "content" {   
  bucket = "${var.bucket_name}-${var.environment}"  
  tags = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse_config" {
	bucket = aws_s3_bucket.content.id
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}	
}

resource "aws_s3_bucket_acl" "acl" {
	bucket = aws_s3_bucket.content.id
	acl = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_public_block" {
	bucket = aws_s3_bucket.content.id
	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true 
	restrict_public_buckets = true 
}

resource "aws_s3_bucket_policy" "s3policy" {
	bucket = aws_s3_bucket.content.id
	policy = data.aws_iam_policy_document.s3policy.json
}


# LOGGING BUCKET
# ---------------

resource "aws_s3_bucket" "logs" {   
  bucket = "${var.bucket_name}-${var.environment}-logs"
  tags = local.tags
}

# CLOUDFRONT DISTRO
# ------------------

resource "aws_cloudfront_distribution" "cf" {
	enabled = true
	aliases = [ var.domain ]
	origin {
		domain_name = aws_s3_bucket.content.bucket_regional_domain_name
		origin_id = aws_s3_bucket.content.bucket_regional_domain_name

		s3_origin_config {
			origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
		}
	}

	default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.content.bucket_regional_domain_name
		viewer_protocol_policy = "redirect-to-https"

		forwarded_values {
			headers = []
			query_string = true

			cookies {
				forward = "all"
			}
		}
	}

	restrictions {
		geo_restriction {
			restriction_type = "none"
		} 
	}

	viewer_certificate {
		acm_certificate_arn = aws_acm_certificate.cert.arn
		ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
	}

	price_class = var.price_class

	logging_config {
	  include_cookies = false
	  bucket = aws_s3_bucket.logs.bucket_domain_name
	  prefix = "cdnlogs"
	}

	tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "oai" {
	comment = "OAI for ${var.domain}"
}


resource "aws_cloudfront_response_headers_policy" "cors" {
  name    = "cors-policy"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["GET"] 
    }

    access_control_allow_methods {
      items = ["GET"]
    }

    access_control_allow_origins {
      items = [ var.cors_origin != "" ? var.cors_origin : var.domain ]
    }

    origin_override = true
  }
}


# CERTIFICATE AND DNS
# --------------------

resource "aws_acm_certificate" "cert" {
	provider = aws.us-east-1
	domain_name = var.domain
	validation_method = "DNS"
	tags = local.tags
}

resource "aws_route53_record" "cert_validation" {
	for_each = {
		for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
			name = d.resource_record_name
			record = d.resource_record_value
			type = d.resource_record_type
		}
	}	

	allow_overwrite = true
	name = each.value.name
	records = [each.value.record]
	ttl = 60
	type = each.value.type
	zone_id = data.aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
	provider = aws.us-east-1
	certificate_arn = aws_acm_certificate.cert.arn
	validation_record_fqdns = [ for r in aws_route53_record.cert_validation : r.fqdn ]
}

resource "aws_route53_record" "content_url" {
	name = var.domain
	zone_id = data.aws_route53_zone.domain.zone_id
	type = "A"

	alias {
		name = aws_cloudfront_distribution.cf.domain_name
		zone_id = aws_cloudfront_distribution.cf.hosted_zone_id
		evaluate_target_health = true
	}
}
