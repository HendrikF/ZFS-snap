# ZFS Snap 

ZFS Snap is the idea of using ZFS+CRON+BASH to create a one-stop solution for automatic rolling snapshots.

## License

ZFS Snap is free software and licensed under the GNU GPLv3 or later. You
are welcome to change and redistribute it under certain conditions. For more
information see the LICENSE file or visit http://www.gnu.org/licenses/gpl-3.0.html

## Running ZFS Snap

The script offers several switches to change the default behaviour, which is simply taking a snapshot with a timestamp.

Requirements:

```
bash
zfs
tail
grep
date
sort
xargs
```

Options:

```
-h usage help
-d <default option> : hourly, daily, weekly, monthly, yearly
-l <label> default: Automatic
-r <number> : number of how many of those backups to retain ; default: 10
```

Five default behaviours have been implemented with following settings for label prefix and retention

```
hourly:  h 48 
daily:   d 14
weekly:  w  4
monthly: m 12
yearly:  y  5
```

These default values are overridden by user values.

## Crontab

```
PATH=/bin:/sbin
@hourly /opt/zfs_snap.sh -d hourly
@daily /opt/zfs_snap.sh -d daily
@weekly /opt/zfs_snap.sh -d weekly
@monthly /opt/zfs_snap.sh -d monthly
@yearly /opt/zfs_snap.sh -d yearly
```

The change to the PATH variable might be needed on some systems.

## ZFS properties

The ZFS property `com.sun:auto-snapshot` determines if a ZFS dataset is snapshoted or not.
