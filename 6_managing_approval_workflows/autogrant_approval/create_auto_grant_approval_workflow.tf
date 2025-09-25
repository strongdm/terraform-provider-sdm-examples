# Copyright 2025 strongDM Inc
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

####################################
# Create an auto grant Approval Workflow 
####################################
resource "sdm_approval_workflow" "auto_grant_approval_workflow" {
    name = "auto approval workflow example"
    approval_mode = "automatic"
}

# At this point, the auto grant approval workflow will be created.