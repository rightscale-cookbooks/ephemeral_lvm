#
# Cookbook Name:: fake
# Recipe:: gce
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

# Include the fake::default recipe which sets up the loopback
# devices used in the test.
#
include_recipe "fake"

# Setup the links for ephemeral devices for google by id
#
node['fake']['devices'].each do |device|
  match = device.match(/\/dev\/loop(\d+)/)
  if match.nil?
    next
  else
    device_index = match[1]
  end
  link "/dev/disk/by-id/google-ephemeral-disk-#{device_index}" do
    to device
  end
end
