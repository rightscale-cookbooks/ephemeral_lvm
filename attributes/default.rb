# frozen_string_literal: true
#
# Cookbook Name:: ephemeral_lvm
# Attributes:: default
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

# The ephemeral file system
# RHEL 7 and CentOS 7 uses XFS as their default file system.
default['ephemeral_lvm']['filesystem'] =
  node['platform_family'] == 'rhel' && node['platform_version'] =~ /^7\./ ? 'xfs' : 'ext4'

# The ephemeral mount point
default['ephemeral_lvm']['mount_point'] = '/mnt/ephemeral'

# The ephemeral mount point options
default['ephemeral_lvm']['mount_point_properties'] = {
  options: %w(defaults noauto),
  pass: 0
}

# The ephemeral volume group name
default['ephemeral_lvm']['volume_group_name'] = 'vg-data'

# The logical volume size of the ephemeral disk
default['ephemeral_lvm']['logical_volume_size'] = '100%VG'

# The ephemeral logical volume name
default['ephemeral_lvm']['logical_volume_name'] = 'ephemeral0'

# The stripe size in kilobytes to be used if more than one ephemeral disk is found
default['ephemeral_lvm']['stripe_size'] = 512

# Whether to wipe signatures on any existing drives
default['ephemeral_lvm']['wipe_signatures'] = false
