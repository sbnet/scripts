#!/bin/bash
#
# Backup Script
#
# This script make a backup of :
#   * Directories defined in $DIR[], one directory by entry
#   * Databases defined in $DATABASES, one string, each database's name separated by a space
#
# All backup snapshots are timestamped and compressed : <dirname>-YYYY-MM-DD.tgz and <dirname>-YYYY-MM-DD.sql.tgz
# They are stored in a local temp directory ($TMP_DIR)
#
# They can also be uploaded to a ftp server, juste activate it by setting $UPLOAD_TO_FTP to true and configure the ftp section
# Older snapshots on the ftp are deleted, only one week (7 days) of snapshots are kept.
#
# An optionnal md5 file can also be generated, set the $GENERATE_MD5 variable to true or false
#
# Additionnal parameters can be used :
#   * REMOVE_LOCAL = keep or not a local copy of the snapshots
#   * ROTATE_LOCAL = used only if REMOVE_LOCAL is set to false, delete local older (1 month old) snapshots
#
# Author: Stephane BRUN
# Version : 1.0

REMOVE_LOCAL=true
ROTATE_LOCAL=true
UPLOAD_TO_FTP=false
GENERATE_MD5=true

# ftp
FTP_HOST=""
FTP_USER=""
FTP_PASS=""
FTP_DEST=""

# database
DB_HOST="localhost"
DB_USER=""
DB_PASS=""

# what to backup ?
# directories are stored in an array, one directory by entry
DIRS[1]="/etc"
DIRS[2]="/home/one"
DIRS[3]="/home/two"

# databases are in a string, separated by a space
DATABASES="dbone dbtwo"

# dirs
TMP_DIR="/tmp/backup"

#############################################################
TODAY=$(date --iso)                   # Today's date like YYYY-MM-DD
RMDATE=$(date --iso -d 'last month')  # TODAY minus X days - too old files

# create the temp dir if it doesn't exist
if [ ! -d "$TMP_DIR" ]; then
  mkdir -p TMP_DIR
fi

# remove local files in $TMP_DIR
# keep only the current backup
if $REMOVE_LOCAL ; then
  rm $TMP_DIR/*
elif $ROTATE_LOCAL ; then
  rm $TMP_DIR/*$RMDATE*
fi

# backup files
nb=${#DIRS[@]}
for (( i=1; i<=nb; i++ ))
do
  cd ${DIRS[$i]}

  # replace all / by -
  NAME=${DIRS[$i]//[\/]/-}

  # remove first - if any
  NAME=`echo $NAME | sed 's/^-//'`

  # backup
  tar -czf $TMP_DIR/$NAME-$TODAY.tgz .
done

# backup databases
for DB in $DATABASES ; do
  mysqldump --force --opt --user=$DB_USER --password=$DB_PASS --databases $DB > $TMP_DIR/$DB-$TODAY.sql
  tar -czf $TMP_DIR/$DB-$TODAY.sql.tgz $TMP_DIR/$DB-$TODAY.sql
  rm $TMP_DIR/$DB-$TODAY.sql
done

# generate the md5 file
if $GENERATE_MD5 ; then
  md5sum $TMP_DIR/*.tgz > $TMP_DIR/files.md5
fi

# send the files to the backup server
# and remove older backup directory
#if $UPLOAD_TO_FTP ; then
#fi

