#!/bin/bash

if [ -z "${DAYS_RETENTION}" ]; then
  # Default to 60 days
  DAYS_RETENTION=1825
fi

BUCKET_NAME="BUCKET_NAME"
DATABASE="DATABASE_NAME"
SQL_INSTANCE="SQL_INSTANCE"

# Author: Patrick Morin, Esokia
# export database from instance and create a snapshot
gcloud sql export sql "${SQL_INSTANCE}" gs://"${BUCKET_NAME}"/sqldumpfile-"$(date '+%Y-%m-%d-%s')".sql.gz --database "${DATABASE}"
#
# snapshots are incremental and dont need to be deleted, this script deletes them after n days
#
if [[ $(uname) == "Linux" ]]; then
  from_date=$(date -d "-${DAYS_RETENTION} days" "+%Y-%m-%d")
else
  from_date=$(date -v -${DAYS_RETENTION}d "+%Y-%m-%d")
fi
gsutil rm -r gs://"${BUCKET_NAME}"/sqldumpfile-"${from_date}"*
#
