#
# Cookbook Name:: ephemeral_lvm
# Spec:: spec_helper
#
# Copyright (C) 2014 RightScale, Inc.
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
libraries_path = File.expand_path('../../libraries', __FILE__)
$LOAD_PATH.unshift(libraries_path) unless $LOAD_PATH.include?(libraries_path)

require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require 'rspec/support'

ChefSpec::Coverage.start!
RSpec.configure do |config|
  config.extend(ChefSpec::Cacher)
  config.platform = 'ubuntu'
  config.version = '12.04'
  config.log_level = :error
end
