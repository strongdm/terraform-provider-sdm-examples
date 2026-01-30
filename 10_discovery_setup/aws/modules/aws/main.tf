terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  # Strip leading http(s):// so we can build condition keys like:
  #   "app.strongdm.com/oidc/foobar-org:aud"
  #   "app.strongdm.com/oidc/foobar-org:sub"
  issuer_hostpath = trimprefix(
    trimprefix(var.issuer_url, "https://"),
    "http://"
  )
  issuer_parts = split("/", var.issuer_url)
  subdomain    = local.issuer_parts[length(local.issuer_parts) - 1]
  audiences    = ["sdm:${local.subdomain}"]
  subjects = (
    length(var.connector_ids) > 0 ?
    [for x in var.connector_ids : "sdm:${local.subdomain}:${x}"] :
    ["sdm:${local.subdomain}:*"]
  )
}

resource "aws_iam_openid_connect_provider" "discovery" {
  url            = var.issuer_url
  client_id_list = local.audiences
}

resource "aws_iam_role" "discovery" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.discovery.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          # audiences (aud) must be one of the allowed audiences
          StringEquals = {
            "${local.issuer_hostpath}:aud" = local.audiences
          }
          # subs may include wildcards, so use StringLike
          StringLike = {
            "${local.issuer_hostpath}:sub" = local.subjects
          }
        }
      }
    ]
  })
}

# Attach default AWS ReadOnlyAccess managed policy
resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.discovery.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
