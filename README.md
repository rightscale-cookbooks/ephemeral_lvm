# ephemeral_lvm cookbook

[![Build Status](https://travis-ci.org/rightscale-cookbooks/ephemeral_lvm.png?branch=master)](https://travis-ci.org/rightscale-cookbooks/ephemeral_lvm)

This cookbook will identify the ephemeral devices available on the instance based on Ohai data. If no ephemeral devices
are found, it will gracefully exit with a log message. If ephemeral devices are found, they will be setup to
use LVM and a logical volume will be created, formatted, and mounted. If multiple ephemeral devices are found
(e.g. m1.large on EC2 has 2 ephemeral devices with 420 GB each), they will be striped to create the LVM.

# Requirements

* Chef 10 or higher
* A cloud that supports ephemeral devices. Currently supported clouds: EC2, Openstack, and Google.
* The [lvm](http://community.opscode.com/cookbooks/lvm) cookbook

# Attributes

The following are the attributes used by the this cookbook.
<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node['ephemeral_lvm']['filesystem']</tt></td>
    <td>The filesystem to be used on the ephemeral volume</td>
    <td><tt>'ext4'</tt></td>
  </tr>
  <tr>
    <td><tt>node['ephemeral_lvm']['mount_point']</tt></td>
    <td>The mount point for the ephemeral volume</td>
    <td><tt>'/mnt/ephemeral'</tt></td>
  </tr>
  <tr>
    <td><tt>node['ephemeral_lvm']['volume_group_name']</tt></td>
    <td>The volume group name for the ephemeral LVM</td>
    <td><tt>'vg-data'</tt></td>
  </tr>
  <tr>
    <td><tt>node['ephemeral_lvm']['logical_volume_size']</tt></td>
    <td>The size to be used for the ephemeral LVM</td>
    <td><tt>'100%VG'</tt> - This will use all available space in the volume group</td>
  </tr>
  <tr>
    <td><tt>node['ephemeral_lvm']['logical_volume_name']</tt></td>
    <td>The name of the logical volume for ephemeral LVM</td>
    <td><tt>'ephemeral0'</tt></td>
  </tr>
  <tr>
    <td><tt>node['ephemeral_lvm']['stripe_size']</tt></td>
    <td>The stripe size to be used for the ephemeral logical volume</td>
    <td><tt>512</tt></td>
  </tr>
</table>

# Usage

Place the `ephemeral_lvm::default` in the runlist and the ephemeral devices will be setup.

# Recipes

## default

This recipe sets up available ephemeral devices to be an LVM device, formats it, and mounts it.

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
