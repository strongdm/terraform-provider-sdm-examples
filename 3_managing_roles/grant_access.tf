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
# Create a Resource (e.g., Postgres)
#################
resource "sdm_resource" "make" {
  postgres = jsonencode(
    [
      {
        name                       = "Example Postgres Resource",
        hostname                   = "example.strongdm.com",
        port                       = "1306",
        database                   = "postgres",
        secret_store_id            = "se-123e45678901bb23",
        secret_store_username_path = "example/sdm?key=user",
        secret_store_password_path = "example/sdm?key=pw"
      }
    ])
}

#################
# Create a Role with Access Rule
#################
resource "sdm_role" "example-role" {
  name = "example-role"
  access_rules {
    ids = [sdm_resource.make.id]
  }
}

#################
# Grant access
#################
# When using Access Rules, the best practice is to give Roles access to Resources based on
type and tags.

resource "sdm_role" "example-role" {
  name = "example-role"

  # Example: Grant access to all dev environment Resources in us-west region
  access_rules = jsonencode(
    [
      { tags = { env = "dev", region = "us-west" } }
    ])
}

  # Example: Grant access to all Postgres Resources
  access_rules {
    type = "postgres"
  }

  # Grant access to all Redis Datasources in us-east region
  access_rules {
    type = "redis"
    tags = jsonencode(
    [
      { tags = { region = "us-east" } }
    ])
  }
}

# If it is _necessary_ to grant access to specific Resources in the same way as
Role Grants did, you can use Resource IDs directly in Static Access Rules.

resource "sdm_role" "engineering" {
  name = "engineering"
  access_rules {
    ids = [sdm_resource.redis-test.id, sdm_resource.postgres-test.id]
  }
}

#################
# Create a User
#################
resource "sdm_account" "example_user" {
  user = jsonencode(
    [
      {
        first_name = "example",
        last_name  = "example",
        email      = "example@strongdm.com",
        suspended  = false
      }
    ])
}

#################
# Attach the User to the Role
#################
resource "sdm_account_attachment" "example_account_attachment" {
  account_id = sdm_account.example_user.id
  role_id    = sdm_role.example_role.id
}
