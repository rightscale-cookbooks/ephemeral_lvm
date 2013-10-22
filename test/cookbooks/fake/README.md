# fake cookbook

# Requirements

Requires the `ephemeral_lvm` cookbook.

# Usage

This cookbook is only used to test the `ephemeral_lvm` cookbook.

# Attributes

`node['fake']['devices']` - The ephemeral devices to be used for testing

# Recipes

## default

This recipe prepares the server with some loop devices as ephemeral disks.

## gce

This recipe prepares the server to mimic the behavior of GCE cloud by setting up the links to ephemeral devices.

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
