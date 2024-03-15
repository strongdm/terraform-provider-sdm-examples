#################
# Create a User and Role
#################
resource "sdm_account" "john" {
  user {
    first_name = "John"
    last_name  = "Doe"
    email      = "john@doe.com"
  }
}
resource "sdm_account_attachment" "john_terraform" {
  account_id = sdm_account.john.id
  role_id    = sdm_role.terraform.id
}
resource "sdm_role" "terraform" {
  name = "Terraform Role"
}

#################
# Create Oracle 19 DB
#################
resource "aws_db_instance" "rds" {
  engine                 = "Oracle-ee"
  publicly_accessible    = true
  engine_version         = "19"
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

#################
# Add Oracle DB to strongDM
#################
resource "sdm_resource" "oracle" {
  oracle {
    name         = "Oracle_19_RDS_instance"
    hostname     = aws_db_instance.rds.address
    database     = aws_db_instance.rds.name
    username     = aws_db_instance.rds.username
    password     = aws_db_instance.rds.password
    port         = 1521
    tls_required = false
  }
}

#################
# Grant datasource access to role
#################
resource "sdm_role_grant" "oracle" {
  role_id     = sdm_role.terraform.id
  resource_id = sdm_resource.oracle.0.id
}

