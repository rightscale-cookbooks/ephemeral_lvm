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

# Include the lvm::default recipe which sets up the resources/providers for lvm
#
include_recipe "lvm"

if !node.attribute?('cloud') || !node['cloud'].attribute?('provider')
  log "Not running on a known cloud, not setting up ephemeral LVM"
else
  ephemeral_devices = []
  cloud = node['cloud']['provider']
  # Detects the ephemeral disks available on the instance.
  #
  # If the cloud plugin supports block device mapping on the node, obtain the
  # information from the node for setting up block device
  #
  if node[cloud].keys.any? { |key| key.match(/block_device_mapping_ephemeral\d+/) }
    ephemeral_devices = node[cloud].keys.collect do |key|
      if key.match(/block_device_mapping_ephemeral\d+/)
        node[cloud][key].match(/\/dev\//) ? node[cloud][key] : "/dev/#{node[cloud][key]}"
      end
    end

    # Removes nil elements from the ephemeral_devices array if any.
    ephemeral_devices.compact!

    # Servers running on Xen hypervisor require the block device to be in /dev/xvdX instead of /dev/sdX
    if node.attribute?('virtualization') && node['virtualization']['system'] == "xen"
      Chef::Log.info "Mapping for devices: #{ephemeral_devices.inspect}"
      ephemeral_devices = EphemeralLvm::Helper.fix_device_mapping(
        ephemeral_devices,
        node['block_device'].keys
      )
    log "Ephemeral disks found for cloud '#{cloud}': #{ephemeral_devices.inspect}"
    end
  else
    # Cloud specific ephemeral detection logic if the cloud doesn't support block_device_mapping
    #
    case cloud
    when 'gce'
      # According the GCE documentation, the instances have links for ephemeral disks as
      # /dev/disk/by-id/google-ephemeral-disk-*. Refer
      # https://developers.google.com/compute/docs/disks#scratchdisks for more information.
      #
      ephemeral_devices = node[cloud]['attached_disks']['disks'].collect do |disk|
        if disk['type'] == "EPHEMERAL" && disk['deviceName'].match(/ephemeral-disk-\d+/)
          "/dev/disk/by-id/google-#{disk["deviceName"]}"
        end
      end
      # Removes nil elements from the ephemeral_devices array if any.
      ephemeral_devices.compact!
    else
      log "Cloud '#{cloud}' doesn't have ephemeral disks or this cookbook doesn't support that cloud"
    end
  end



  if ephemeral_devices.empty?
    log "No ephemeral disks found. Skipping setup."
  else
    log "Ephemeral disks found for cloud '#{cloud}': #{ephemeral_devices.inspect}"

    # Creates physical volumes for all ephemeral disks.
    ephemeral_devices.each do |device|
      lvm_physical_volume device
    end

    # Create the volume group and logical volume. If more than one ephemeral disks are found,
    # they are created with LVM stripes with the stripe size set in the attributes.
    #
    lvm_volume_group node['ephemeral_lvm']['volume_group_name'] do
      physical_volumes ephemeral_devices

      logical_volume node['ephemeral_lvm']['logical_volume_name'] do
        size node['ephemeral_lvm']['logical_volume_size']
        filesystem node['ephemeral_lvm']['filesystem']
        mount_point node['ephemeral_lvm']['mount_point']
        if ephemeral_devices.size > 1
          stripes ephemeral_devices.size
          stripe_size node['ephemeral_lvm']['stripe_size']
        end
      end
    end
  end
end
