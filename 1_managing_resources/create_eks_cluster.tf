# Copyright 2020 StrongDM Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource "sdm_resource" "eks" {
  amazon_eks {
    name         = "Example EKS Cluster"
    cluster_name = "example"

    endpoint = "https://A1ADBDD0AE833267869C6ED0476D6B41.gr7.us-east-2.eks.amazonaws.com"
    region   = "us-east-1"

    certificate_authority          = local.certificate_authority
    certificate_authority_filename = "random_string"

    access_key        = "AKIAIOSFODNN7EXAMPLE"
    secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    role_arn          = "arn:aws:iam::000000000000:role/RoleName"

    healthcheck_namespace = "default"
  }
}

locals {
  certificate_authority = <<CERT
-----BEGIN CERTIFICATE-----
MIICpjCCAY4CCQCYJT6s+JVzSTANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApr
dWJlcm5ldGVzMB4XDTIwMDcxNTE0MjgzN1oXDTIxMDcxNTE0MjgzN1owFTETMBEG
A1UEAwwKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AJtI1pfbqy65FihJ6SadnrdDw6IjGJo7icoxcDR9Tn0Ljz7a7CO4VgpDfs/X4ljG
LkGTqDqLXZ61+lssfaUwMFA61McthTZfd6rYLBcxWFmaVqvUL0tguTrrUPuegHXv
IBs827JSH43BXqLgvZCaWYb5PtD+CI9F9bOBm+M+BUufrdS6gUkTqipZdgC8sl8E
SvixPjKPRu4EnBE/cPEMvYzkSpjixs87WKGPR0FM+6SQVr6o14Fs3QNlcElBAi27
U7XL+an/Fj0osEZGDhJ1u/TmmWlW7RopE1YS8gpVxBzQkBmeUU05a9l1f4L8j45E
TFuF5daWkNLZFO08u1GxnlsCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEANyPDqSUZ
nLiOVGg4OWPmXJy3tk7+Mb6j/xOFFKoKfrXJVUB1F5IDMD673ozkhKyNcqfFOEeZ
+E3WC2/CxxwkJfEUrtij8qWMnafvDnaPan86jNkZsz9zvxphqdeA0hsYZF5tPLWT
Sk8uIHuRA36mYhzCrXQ7dhLn4mC147LRcZ73CTi4j4bNyGtCYgYE+Ta1pcrREIHp
PMiZH+tzwXAWeVKh3foHTjeXKAgXhg3Lbqxn6Uq3cejraUMi9b489KKPOlcaQ7wX
FPkubmy3vrhgJySlrfBDtCgFDwSosLniZU479S3oZBsKgPgLe3ELzAw1vLcuIgmd
JrXnKV7Z4r9uWg==
-----END CERTIFICATE-----
CERT
}