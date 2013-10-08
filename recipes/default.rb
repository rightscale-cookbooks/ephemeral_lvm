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
  # Obtain the current cloud
  cloud = node['cloud']['provider']

  # Obtain the available ephemeral devices. See "libraries/helper.rb" for the definition of
  # "get_ephemeral_devices" method.
  #
  ephemeral_devices = EphemeralLvm::Helper.get_ephemeral_devices(cloud, node)

  if ephemeral_devices.empty?
    log "No ephemeral disks found. Skipping setup."
  else
    log "Ephemeral disks found for cloud '#{cloud}': #{ephemeral_devices.inspect}"

    # Create the volume group and logical volume. If more than one ephemeral disk is found,
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
          stripe_size node['ephemeral_lvm']['stripe_size'].to_i
        end
      end
    end
  end
end
