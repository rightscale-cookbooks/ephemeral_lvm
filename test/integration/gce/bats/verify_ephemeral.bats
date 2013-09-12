#/usr/bin/env bats

# On CentOS 5.9, most of the commands used here are not in PATH. So add them
# here.
export PATH=$PATH:/sbin:/usr/sbin

@test "google ephemeral disk by-id symbolic links exist" {
  test -L /dev/disk/by-id/google-ephemeral-disk-0
  test -L /dev/disk/by-id/google-ephemeral-disk-1
}

@test "physical volumes are created for ephemeral devices" {
  pvs | grep /dev/loop0
  pvs | grep /dev/loop1
}

@test "volume group is created for ephemeral devices" {
  vgs | grep vg-data
}

@test "logical volume is created for ephemeral devices on the correct volume group" {
  lvs | grep vg-data | grep lvol0
}


# The `lvs --segments --separator :` command outputs in the following format
# 'LV:VG:Attr:#Str:Type:SSize' where '#Str' is the number of stripes and 'Type' is 'striped'
# if the LVM is striped and 'linear' otherwise.
#
@test "logical volumes are striped" {
  lvs --segments --separator : | grep -P "lvol0:vg-data.*:2:striped"
}

@test "ephemeral logical volume is mounted to /mnt/ephemeral" {
  mountpoint /mnt/ephemeral
  mount | grep "/dev/mapper/vg--data-lvol0 on /mnt/ephemeral type ext3"
  grep -P "/dev/mapper/vg--data-lvol0\s+/mnt/ephemeral\s+ext3" /etc/fstab
}
