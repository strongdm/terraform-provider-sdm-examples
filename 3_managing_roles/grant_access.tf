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
# Create a datasource
#################
resource "sdm_resource" "postgres_example" {
  postgres {
    name = "Example Postgres Datasource"

    hostname = "example.strongdm.com"
    port     = 5432

    username = "example"
    password = "example"

    database = "example"
  }
}

#################
# Create a role
#################
resource "sdm_role" "example_role" {
  name = "example role"
}

#################
# Grant the role access to the datasource
#################
resource "sdm_role_grant" "example_role_grant" {
  role_id     = sdm_role.example_user.id
  resource_id = sdm_resource.postgres_example.id
}

#################
# Create a user
#################
resource "sdm_account" "example_user" {
  user {
    first_name = "example"
    last_name  = "example"
    email      = "example@strongdm.com"
    suspended  = false
  }
}

#################
# Attach the user to the role
#################
resource "sdm_account_attachment" "example_account_attachment" {
  account_id = sdm_account.example_user.id
  role_id    = sdm_role.example_role.id
}
