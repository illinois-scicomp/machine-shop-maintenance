#! /bin/sh

# *only* run on on stout and dunkel

rsync --archive --delete -v /shared /shared-backup
