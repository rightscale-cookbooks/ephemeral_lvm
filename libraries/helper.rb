# frozen_string_literal: true

#
# Cookbook Name:: ephemeral_lvm
# Library:: helper
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

module EphemeralLvm
  module Helper
    # Identifies the ephemeral devices available on a cloud server based on cloud-specific Ohai data and returns
    # them as an array. This method also does the mapping required for Xen hypervisors (/dev/sdX -> /dev/xvdX).
    #
    # @param cloud [String] the name of cloud
    # @param node [Chef::Node] the Chef node
    def self.gce_ephemeral_devices?(cloud, node)
      # According to the GCE documentation, the instances have links for ephemeral disks as
      # /dev/disk/by-id/google-ephemeral-disk-*. Refer to
      # https://developers.google.com/compute/docs/disks#scratchdisks for more information.
      #
      unless node[cloud]['attached_disks'].nil?
        ephemeral_devices = node[cloud]['attached_disks']['disks'].map do |disk|
          if ((disk['type'] == 'EPHEMERAL') || (disk['type'] == 'LOCAL-SSD')) && disk['deviceName'].match(/^local-ssd-\d+$/)
            "/dev/disk/by-id/google-#{disk['deviceName']}"
          end
        end
      end

      unless node[cloud]['instance'].nil?
        ephemeral_devices = node[cloud]['instance']['disks'].map do |disk|
          if disk['type'] == 'LOCAL-SSD' && disk['deviceName'].match(/^local-ssd-\d+$/)
            "/dev/disk/by-id/google-#{disk['deviceName']}"
          end
        end
      end

      # Removes nil elements from the ephemeral_devices array if any.
      ephemeral_devices.compact!
      ephemeral_devices
    end

    # @param cloud [String] the name of cloud
    # @param node [Chef::Node] the Chef node
    def self.ec2_ephemeral_devices?(_cloud, node)
      # Find all NVMe devices that are present on newer instance types but aren't listed in metadata
      unless node['filesystem'].nil? || node['filesystem']['by_device'].nil?
        nvme_devices = node['filesystem']['by_device'].keys.select { |device| device =~ %r{\/dev\/nvme\d+n\d+$} }
        Chef::Log.info "Available NVMe devices: #{nvme_devices}"
        # Find any NVMe devices with mounted partitions - typically root volume on 5th generation of instances
        nvme_devices_mounted = node['filesystem']['by_pair'].keys.map do |pair|
          # Split device,mountpoint string into an array
          pair_array = pair.split(',')
          # Check if device is NVMe device and has a valid mountpoint
          if pair_array[0] =~ %r{\/dev\/nvme\d+n\d+} && pair_array.size > 1
            # Return main device for a mounted partition
            pair_array[0][%r{\/dev\/nvme\d+n\d+}]
          end
        end.compact
        Chef::Log.info "Mounted NVMe devices: #{nvme_devices_mounted}"
        ephemeral_devices = nvme_devices - nvme_devices_mounted
        Chef::Log.info "Usable devices: #{ephemeral_devices}"
        ephemeral_devices
      end
    end

    # Identifies the ephemeral devices available on a cloud server based on cloud-specific Ohai data and returns
    # them as an array. This method also does the mapping required for Xen hypervisors (/dev/sdX -> /dev/xvdX).
    #
    # @param cloud [String] the name of cloud
    # @param node [Chef::Node] the Chef node
    # @return [Array<String>] list of ephemeral available ephemeral devices.
    #
    def self.get_ephemeral_devices(cloud, node)
      ephemeral_devices = []
      # Detects the ephemeral disks available on the instance.
      #
      # If the cloud plugin supports block device mapping on the node, obtain the
      # information from the node for setting up block device
      #
      if node[cloud].keys.any? { |key| key.match(/^block_device_mapping_ephemeral\d+$/) }
        ephemeral_devices = node[cloud].map do |key, device|
          if key =~ /^block_device_mapping_ephemeral\d+$/
            device =~ %r{\/dev\/} ? device : "/dev/#{device}"
          end
        end

        # Removes nil elements from the ephemeral_devices array if any.
        ephemeral_devices.compact!

        # Servers running on Xen hypervisor require the block device to be in /dev/xvdX instead of /dev/sdX
        if !node['virtualization'].nil? && node['virtualization']['system'] == 'xen'
          Chef::Log.info "Mapping for devices: #{ephemeral_devices.inspect}"
          ephemeral_devices = EphemeralLvm::Helper.fix_device_mapping(
            ephemeral_devices,
            node['block_device'].keys
          )
          Chef::Log.info "Ephemeral disks found for cloud '#{cloud}': #{ephemeral_devices.inspect}"
        end
      else
        # Cloud specific ephemeral detection logic if the cloud doesn't support block_device_mapping
        #
        case cloud
        when 'gce'
          ephemeral_devices = gce_ephemeral_devices?(cloud, node)
        when 'ec2'
          ephemeral_devices = ec2_ephemeral_devices?(cloud, node)
        else
          Chef::Log.info 'No ephemeral disks found.'
        end
      end
      ephemeral_devices.concat(node['ephemeral_lvm']['additonal_devices']).uniq
    end

    # Fixes the device mapping on Xen hypervisors. When using Xen hypervisors, the devices are mapped from /dev/sdX to
    # /dev/xvdX. This method will identify if mapping is required (by checking the existence of unmapped device) and
    # map the devices accordingly.
    #
    # @param devices [Array<String>] list of devices to fix the mapping
    # @param node_block_devices [Array<String>] list of block devices currently attached to the server
    #
    # @return [Array<String>] list of devices with fixed mapping
    #
    def self.fix_device_mapping(devices, node_block_devices)
      devices.map! do |device|
        if node_block_devices.include?(device.match(%{\/dev\/(.+)$})[1])
          device
        else
          fixed_device = device.sub('/sd', '/xvd')
          if node_block_devices.include?(fixed_device.match(%{\/dev\/(.+)$})[1])
            fixed_device
          else
            Chef::Log.warn "could not find ephemeral device: #{device}"
            nil
          end
        end
      end
      devices.compact
    end
  end
end
