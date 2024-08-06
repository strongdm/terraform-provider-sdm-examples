# Copyright 2024 strongDM Inc
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

# Creates a Policy that forbids all principals from connecting to it.
resource "sdm_policy" "forbid_the_bad_connect" {
  name = "forbid-the-bad-resource"
  description = "Forbid connecting to the bad resource."

  policy = <<EOP
forbid (
     principal,
     action == StrongDM::Action::"connect",
     resource == StrongDM::Resource::"rs-123d456789"
);
EOP
}
