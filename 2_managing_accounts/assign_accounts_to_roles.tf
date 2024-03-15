# Copyright 2020 strongDM Inc
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

#################
# Create a User
#################
resource "sdm_account" "example_user_2" {
  user {
    first_name = "Example"
    last_name  = "Example"
    email      = "terraform-assign-accounts-example@example.com"
  }
}

##################################
# Create a Role with Access Rule
##################################
resource "sdm_role" "example_role" {
  name = "terraform-assign-accounts-example-role"
}

###############################
# Attach the User to the Role
###############################
resource "sdm_account_attachment" "example_attachment" {
  account_id = sdm_account.example_user_2.id
  role_id    = sdm_role.example_role.id
}

