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

## Notes on detection of ephemeral devices on newer AWS EC2 instance types
With the following instances, EBS volumes are exposed as NVMe block devices: `c5`, `c5d`, `i3.metal`, `m5`, and `m5d`. The device names are `/dev/nvme0n1`, `/dev/nvme1n1`, and so on. The device names that you specify in a block device mapping are renamed using NVMe device names (`/dev/nvme[0-26]n1`). [https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html)

This also affects ephemeral SSD devices that are always attached and for which the mapping isn't present in metadata. The current cookbook version tries to find all NVMe devices that aren't mounted.

Note 1) Instance type `i3` is a special case which allows you to map the ephemeral SSDs although there's a naming mismatch `/dev/sdb` vs. `/dev/nvme0n1`. In this case you shouldn't "map" the ephemeral volumes when starting the instance as they are always attached and will only be detected if mapping is not present.

Note 2) To keep things simple if you map additional EBS volumes to the instance types mentioned above the cookbook won't make a distinction between ephemeral devices and EBS volumes and will include all in the logical volume.

# Attributes

* `node['ephemeral_lvm']['filesystem']` - the filesystem to be used on the ephemeral volume. Default: `'ext4'`
* `node['ephemeral_lvm']['mount_point']` - the mount point for the ephemeral volume. Default: `'/mnt/ephemeral'`
* `node['ephemeral_lvm']['mount_point_properties']` - the options used when mounting the ephemeral volume. Default: `{options: ['defaults', 'noauto'], pass: 0}`
* `node['ephemeral_lvm']['volume_group_name']` - the volume group name for the ephemeral LVM. Default: `'vg-data'`
* `node['ephemeral_lvm']['logical_volume_size']` - the size to be used for the ephemeral LVM. Default: `'100%VG'` - This will use all available space in the volume group.
* `node['ephemeral_lvm']['logical_volume_name']` - the name of the logical volume for ephemeral LVM. Default: `'ephemeral0'`
* `node['ephemeral_lvm']['stripe_size']` - the stripe size to be used for the ephemeral logical volume. Default: `512`
* `node['ephemeral_lvm']['additonal_devices']` - array of additional devices to add to stripe.  Use if we are not finding them in metadata.  default: []

# Recipes

## default

This recipe sets up available ephemeral devices to be an LVM device, formats it, and mounts it.

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
