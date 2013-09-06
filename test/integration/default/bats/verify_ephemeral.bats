#/usr/bin/env bats

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

@test "ephemeral logical volume is mounted to /mnt/ephemeral" {
  mountpoint /mnt/ephemeral
  mount | grep "/dev/mapper/vg--data-lvol0 on /mnt/ephemeral type ext4"
  grep -P "/dev/mapper/vg--data-lvol0\s+/mnt/ephemeral\s+ext4" /etc/fstab
}
