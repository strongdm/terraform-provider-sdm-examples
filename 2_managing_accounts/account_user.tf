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

resource "sdm_account" "alice" {
  user {
    first_name = "Alice"
    last_name  = "Glick"
    email      = "alice.glick@example.com"
    permission_level  = "multi-team-leader"
  }
}
resource "sdm_account_attachment" "alice_terraform" {
  account_id = sdm_account.alice.id
  role_id    = sdm_role.terraform.id
}
resource "sdm_role" "terraform" {
  name = "Terraform Role"
}
