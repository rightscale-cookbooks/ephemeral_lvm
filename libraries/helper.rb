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
    def self.fix_device_mapping(devices, node_block_devices)
      fixed_devices = devices.map do |device|
        fixed_device = device.sub("/sd", "/xvd")
        fixed_device if node_block_devices.include?(fixed_device.match(/\/dev\/([a-z]+)$/)[1])
      end
      fixed_devices.compact
    end
  end
end
