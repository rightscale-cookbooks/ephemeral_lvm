#
# Cookbook Name:: ephemeral_lvm-test
# Recipe:: prepare
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if !node.attribute?('cloud') || !node['cloud'].attribute?('provider')
  log "Not running on a known cloud, Skipping preparation."
else
  cloud = node['cloud']['provider']
  ephemeral_devices = node[cloud].keys.collect do |key|
    if key.match(/block_device_mapping_ephemeral\d+/)
      node[cloud][key].match(/\/dev\//) ? node[cloud][key] : "/dev/#{node[cloud][key]}"
    end
  end

  EphemeralLvmTest::Helper.create_loop_devices(ephemeral_devices)
end
