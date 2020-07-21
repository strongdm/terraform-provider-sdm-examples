resource "sdm_account" "john" {
  user {
    first_name = "John"
    last_name  = "Doe"
    email      = "john@doe.com"
    suspended  = false
  }
}
resource "sdm_account_attachment" "john_terraform" {
  account_id = sdm_account.john.id
  role_id    = sdm_role.terraform.id
}
resource "sdm_role" "terraform" {
  name = "Terraform Role"
}
