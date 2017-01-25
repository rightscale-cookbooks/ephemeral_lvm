# frozen_string_literal: true
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
Chef::Log.info 'including fake recipe'
include_recipe 'fake'

# Setup the links for ephemeral devices for google by id
#
node['fake']['devices'].each do |device|
  match = device.match(%r{\/dev\/loop(\d+)})
  next if match.nil?
  device_index = match[1]
  Chef::Log.info "adding in device: #{device}"
  link "/dev/disk/by-id/google-local-ssd-#{device_index}" do
    to device
    action :nothing
  end.run_action(:create)
end
