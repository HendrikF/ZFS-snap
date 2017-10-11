#!/usr/bin/env bash
#
# zfs_snap.sh
# Copyright 2012 Nils Bausch
# License: GNU GPL Version 3 or later
#
# take ZFS snapshots with a time stamp

usage () {
    [ "$#" -ne 0 ] && echo "$@" >&2
    echo "Usage: $(basename $0) [-h] [-d presetName] [-l labelprefix] [-r <num>]" >&2
    exit 2
}

# property used to check if auto updates should be made or not
SNAPSHOT_PROPERTY_NAME="com.sun:auto-snapshot"
SNAPSHOT_PROPERTY_VALUE="true"

[ "$#" -eq 0 ] && usage

PRESET=
LABELPREFIX="Automatic"
LABEL="$(date +"%Y%m%d-%H%M%S")"
RETENTION=10

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h | --help)
            usage
            ;;
        -d | --default)
            [ "$#" -ge 2 ] || usage "Missing argument"
            shift
            PRESET="$1"
            ;;
        -l | --label)
            [ "$#" -ge 2 ] || usage "Missing argument"
            shift
            USER_PREFIX="$1"
            ;;
        -r | --retention)
            [ "$#" -ge 2 ] || usage "Missing argument"
            shift
            USER_RETENTION="$1"
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            ;;
    esac
    shift
done

# go through possible presets if available
if [ -n "$PRESET" ]; then
    case "$PRESET" in
    hourly)
        LABELPREFIX="h"
        RETENTION=48
        ;;
    daily)
        LABELPREFIX="d"
        RETENTION=14
        ;;
    weekly)
        LABELPREFIX="w"
        RETENTION=4
        ;;
    monthly)
        LABELPREFIX="m"
        RETENTION=12
        ;;
    yearly)
        LABELPREFIX="y"
        RETENTION=5
        ;;
    *)  echo "Unknown default option" >&2
        exit 1
        ;;
    esac
fi

# if these variables are set they will override the preset
[ -z "${USER_PREFIX+x}" ] || LABELPREFIX="$USER_PREFIX"
[ -z "${USER_RETENTION+x}" ] || RETENTION="$USER_RETENTION"

# available datasets for backup
readarray -t datasets < <(zfs list -H -o name)

#TAKE SNAPSHOTS
for dataset in "${datasets[@]}"; do
    # get value of auto-snapshot property, either true or false
    VALUE="$(zfs get "$SNAPSHOT_PROPERTY_NAME" "$dataset" -H -o value)"
    if [ "$VALUE" = "$SNAPSHOT_PROPERTY_VALUE" ]; then
        zfs snapshot "$dataset@$LABELPREFIX-$LABEL"
    fi
done

#DELETE SNAPSHOTS
for dataset in "${datasets[@]}"; do
    # grep for prefix and a dash to not accidentally match anything else
    zfs list -t snapshot -H -o name | grep "$dataset@$LABELPREFIX-" | sort -r | tail -n +$((RETENTION+1)) | xargs -n 1 -r zfs destroy -r
done
