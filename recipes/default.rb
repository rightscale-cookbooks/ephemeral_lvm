#
# Cookbook Name:: ephemeral_lvm
# Recipe:: default
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

include_recipe "lvm"

log "Cloud provider: #{node['cloud'].inspect}"
if !node.attribute?('cloud') || !node['cloud'].attribute?('provider')
  log "Not running on a known cloud, not setting up ephemeral LVM"
else
  ephemeral_devices = []
  cloud = node['cloud']['provider']
  # Detect the ephemeral disks available on the instance
  #
  # If the cloud plugin supports block device mapping on the node, obtain the
  # information from the node for setting up block device
  if node[cloud].keys.any? { |key| key.match(/block_device_mapping_ephemeral\d+/) }
    ephemeral_devices = node[cloud].keys.collect do |key|
      if key.match(/block_device_mapping_ephemeral\d+/)
        node[cloud][key].match(/\/dev\//) ? node[cloud][key] : "/dev/#{node[cloud][key]}"
      end
    end
    log "Ephemeral disks found for cloud '#{cloud}': #{ephemeral_devices.inspect}"
  else
    # Cloud specific ephemeral detection logic if the cloud doesn't support block_device_mapping
    case cloud
    when 'gce'
      # TODO: Google specific stuff goes in here
    else
      log "Cloud '#{cloud}' doesn't have ephemeral disks or this cookbook doesn't support that cloud"
    end
  end

  if ephemeral_devices.empty?
    log "No ephemeral disks found. Skipping setup."
  else
    # Create physical volumes for all ephemeral disks
    ephemeral_devices.each do |device|
      lvm_physical_volume device
    end

    lvm_volume_group node['ephemeral_lvm']['volume_group_name'] do
      physical_volumes ephemeral_devices

      logical_volume node['ephemeral_lvm']['logical_volume_name'] do
        size node['ephemeral_lvm']['logical_volume_size']
        filesystem node['ephemeral_lvm']['filesystem']
        mount_point node['ephemeral_lvm']['mount_point']
        stripes ephemeral_devices.size if ephemeral_devices.size > 1
      end
    end
  end
end
