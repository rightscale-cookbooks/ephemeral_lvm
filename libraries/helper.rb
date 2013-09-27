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
    # Fixes the device mapping on Xen hypervisors.
    #
    # @param devices [Array<String>] list of devices to fix the mapping
    # @param node_block_devices [Array<String>] list of block devices currently attached to the server
    #
    # @return [Array<String>] list of devices with fixed mapping
    #
    def self.fix_device_mapping(devices, node_block_devices)
      devices.map! do |device|
        if node_block_devices.include?(device.match(/\/dev\/([a-z]+)$/)[1])
          device
        else
          fixed_device = device.sub("/sd", "/xvd")
          if node_block_devices.include?(fixed_device.match(/\/dev\/([a-z]+)$/)[1])
            fixed_device
          else
            Chef::Log.warn "could not find ephemeral device: #{device}"
          end
        end
      end
      devices.compact
    end
  end
end
