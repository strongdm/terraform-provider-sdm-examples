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

resource "sdm_resource" "postgres_example" {
  postgres {
    name     = "Example Postgres Datasource"
    hostname = "example.strongdm.com"
    database = "example"
    username = "example"
    password = "example"
    port     = 5432
    tags     = { env = "dev" }
    # Usually, you would omit `port_override` entirely and the port will be 
    # auto-allocated upon creation.
    # Setting `port_override` to `-1` will auto-allocate on a new available 
    # port on every terraform apply.
    port_override = 19999
    # May be set to one of the ResourceIPAllocationMode constants 
    # to select between VNM, loopback, or default IP allocation.
    #
    # If not set, will behave as if configured for "default".
    # For more details on Virtual Networking Mode see documentation here:
    # https://docs.strongdm.com/admin/clients/client-networking/virtual-networking-mode
    bind_interface = "loopback"
    # bind_interface = "vnm"
    # bind_interface = "default"
  }
}

# These flags require some organization configuration to be set
# before these can be created successfully.
locals {
  # set to true if loopback ip range setting is enabled
  # https://docs.strongdm.com/admin/clients/client-networking/loopback-ip-ranges
  enable_loopback_ips = false
  # set to true if Virtual Networking Mode is enabled  
  # https://docs.strongdm.com/admin/clients/client-networking/virtual-networking-mode
  enable_vnm_ips = false
}

resource "sdm_resource" "postgres_loopback_ip" {
  count = local.enable_loopback_ips ? 1: 0
  postgres {
    name     = "Example Postgres Datasource - Loopback IP"
    hostname = "example.strongdm.com"
    database = "example"
    username = "example"
    password = "example"
    port     = 5432
    tags     = { env = "dev" }
    # You can also specify an explicit loopback IP address to bind to if Loopback IP Ranges
    # are enabled as documented here:
    # https://docs.strongdm.com/admin/clients/client-networking/loopback-ip-ranges
    bind_interface = "127.0.0.2"
  }
}

resource "sdm_resource" "postgres_vnm_ip" {
  count = local.enable_vnm_ips ? 1: 0
  postgres {
    name     = "Example Postgres Datasource - VNM IP"
    hostname = "example.strongdm.com"
    database = "example"
    username = "example"
    password = "example"
    port     = 5432
    tags     = { env = "dev" }
    # You can specify an explicit VNM IP address to bind to if 
    # Virtual Networking Mode is enabled:
    bind_interface = "100.64.0.1"
  }
}
