#!/bin/bash

if [ -z "${DAYS_RETENTION}" ]; then
  # Default to 60 days
  DAYS_RETENTION=1825
fi

BUCKET_NAME="BUCKET_NAME"
DATABASE=( "DATABASE_NAME_1" "DATABASE_NAME_2" )
SQL_INSTANCE="SQL_INSTANCE"

# Author: Patrick Morin, Esokia
# authentification with service account
gcloud auth activate-service-account --key-file=/path/to/serviceaccount.json
# export databases from instance and create a snapshot
for db in "${DATABASE[@]}"
do
  gcloud sql export sql "${SQL_INSTANCE}" gs://"${BUCKET_NAME}"/sqldumpfile-"${db}"-"$(date '+%Y-%m-%d-%s')".sql.gz --database "${db}"
done
#
# snapshots are incremental and dont need to be deleted, this script deletes them after n days
#
if [[ $(uname) == "Linux" ]]; then
  from_date=$(date -d "-${DAYS_RETENTION} days" "+%Y-%m-%d")
else
  from_date=$(date -v -${DAYS_RETENTION}d "+%Y-%m-%d")
fi
for db in "${DATABASE[@]}"
do
  gsutil rm -r gs://"${BUCKET_NAME}"/sqldumpfile-"${db}"-"${from_date}"*
done
#
