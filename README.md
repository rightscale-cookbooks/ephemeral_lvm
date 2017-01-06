# ephemeral_lvm cookbook

[![Cookbook](https://img.shields.io/cookbook/v/ephemeral_lvm.svg?style=flat)][cookbook]
[![Release](https://img.shields.io/github/release/rightscale-cookbooks/ephemeral_lvm.svg?style=flat)][release]
[![Build Status](https://img.shields.io/travis/rightscale-cookbooks/ephemeral_lvm.svg?style=flat)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/ephemeral_lvm
[release]: https://github.com/rightscale-cookbooks/ephemeral_lvm/releases/latest
[travis]: https://travis-ci.org/rightscale-cookbooks/ephemeral_lvm

This cookbook will identify the ephemeral devices available on the instance based on Ohai data. If no ephemeral devices
are found, it will gracefully exit with a log message. If ephemeral devices are found, they will be setup to
use LVM and a logical volume will be created, formatted, and mounted. If multiple ephemeral devices are found
(e.g. m1.large on EC2 has 2 ephemeral devices with 420 GB each), they will be striped to create the LVM.

Github Repository: [https://github.com/rightscale-cookbooks/ephemeral_lvm](https://github.com/rightscale-cookbooks/ephemeral_lvm)

# Requirements

* Chef 12 or higher
* A cloud that supports ephemeral devices. Currently supported clouds: EC2, Openstack, and Google.
* Cookbook requirements
  * [lvm](http://community.opscode.com/cookbooks/lvm)
* Platforms
  * Ubuntu 12.04
  * CentOS 6

# Usage

Place the `ephemeral_lvm::default` in the runlist and the ephemeral devices will be setup.

# Attributes

* `node['ephemeral_lvm']['filesystem']` - the filesystem to be used on the ephemeral volume. Default: `'ext4'`
* `node['ephemeral_lvm']['mount_point']` - the mount point for the ephemeral volume. Default: `'/mnt/ephemeral'`
* `node['ephemeral_lvm']['mount_point_properties']` - the options used when mounting the ephemeral volume. Default: `{options: ['defaults', 'noauto'], pass: 0}`
* `node['ephemeral_lvm']['volume_group_name']` - the volume group name for the ephemeral LVM. Default: `'vg-data'`
* `node['ephemeral_lvm']['logical_volume_size']` - the size to be used for the ephemeral LVM. Default: `'100%VG'` - This will use all available space in the volume group.
* `node['ephemeral_lvm']['logical_volume_name']` - the name of the logical volume for ephemeral LVM. Default: `'ephemeral0'`
* `node['ephemeral_lvm']['stripe_size']` - the stripe size to be used for the ephemeral logical volume. Default: `512`

# Recipes

## default

This recipe sets up available ephemeral devices to be an LVM device, formats it, and mounts it.

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
