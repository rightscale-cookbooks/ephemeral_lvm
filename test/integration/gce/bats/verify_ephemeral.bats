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
  lvs | grep vg-data | grep ephemeral0
}

# The `lvs --segments --separator :` command outputs in the following format
# 'LV:VG:Attr:#Str:Type:SSize' where '#Str' is the number of stripes and 'Type' is 'striped'
# if the LVM is striped and 'linear' otherwise.
#
@test "logical volumes are striped" {
  lvs --segments --separator : | grep -P "ephemeral0:vg-data.*:2:striped"
}

@test "ephemeral logical volume is mounted to /mnt/ephemeral" {
  if type -P lsb_release; then
    is_rhel=`lsb_release -sir | grep -Pqiz "^(centos|redHatEnterpriseServer)\s6\." && echo "true" || echo "false"`
  else
    # On RHEL: Red Hat Enterprise Linux Server release 7.1 (Maipo)
    # On CentOS: CentOS Linux release 7.0.1406 (Core)
    is_rhel=`grep -Pqiz "^(centos|red hat enterprise) linux.+ 7\." /etc/redhat-release && echo "true" || echo "false"`
  fi

  if [[ $is_rhel == "true" ]]; then
    filesystem='xfs'
  else
    filesystem='ext4'
  fi
  mountpoint /mnt/ephemeral
  mount | egrep "^/dev/mapper/vg--data-ephemeral0 on /mnt/ephemeral type $filesystem"
  egrep "/dev/mapper/vg--data-ephemeral0\s+/mnt/ephemeral\s+$filesystem\s+defaults,noauto\s+0\s+0" /etc/fstab
}
