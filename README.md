
# Automatic Snapshots for Google Cloud SQL

This is a background bash script to automatically snapshot a specific database on Google cloud SQL in a Google cloud project.

Google Cloud SQL snapshots are only on 7 days. If you need to keep your backup for a longer period, the native backup rule from Google cloud SQL is not suitable. 
You can manage the period to keep the snapshot with this script. This script will default to 60 days. You can change this behavior with an environment variable of DAYS_RETENTION.

## How it works
google-cloud-sql-snapshot.sh will:

- Take a snapshot of the specified database - snapshots prefixed sqldumpfile-{YYYY-MM-DD-sssssssss}.sql.gz
- The script will then delete all associated snapshots taken by the script that are older than 60 days or the value of the environment variable DAYS_RETENTION.


## Prerequisites

* the gcloud SDK must be install which includes the gcloud cli [https://cloud.google.com/sdk/downloads](https://cloud.google.com/sdk/downloads)
* the gcloud project must be set to the project that owns the disks

## Installation

Install the script on any single server ( it will back up ALL disks in a project regardless of the server), the script doesn't even have to run on Google Compute Engine instance, any linux machine will work.

**Install Script**: Download the latest version of the snapshot script and make it executable, e.g. 
```
cd ~
wget https://raw.githubusercontent.com/patrickmorin/google-cloud-sql-snapshot/master/google-cloud-sql-snapshot.sh
chmod +x google-cloud-sql-snapshot.sh
sudo mkdir -p /opt/google-cloud-sql-snapshot
sudo mv google-cloud-sql-snapshot.sh /opt/google-cloud-sql-snapshot/
```


**Setup CRON**: You should then setup a cron job in order to schedule a snapshot as often as you like, e.g. for daily cron:
```
0 5 * * * root /opt/google-cloud-sql-snapshot/google-cloud-sql-snapshot.sh >> /var/log/cron/sql-snapshot.log 2>&1
```

**Manage CRON Output**: Ideally you should then create a directory for all cron outputs and add it to logrotate:

- Create new directory:
```
sudo mkdir /var/log/cron
```
- Create empty file for snapshot log:
```
sudo touch /var/log/cron/snapshot.log
```
- Change permissions on file:
```
sudo chgrp adm /var/log/cron/snapshot.log
sudo chmod 664 /var/log/cron/snapshot.log
```
- Create new entry in logrotate so cron files don't get too big :
```
sudo nano /etc/logrotate.d/cron
```
- Add the following text to the above file:
```
/var/log/cron/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 664 root adm
    sharedscripts
}
```

**To manually test the script:**
```
sudo /opt/google-cloud-auto-snapshot/google-cloud-sql-snapshot.sh
```

## Snapshot Retention

Snapshots are kept for 60 days by default.  You can change this with an environment variable DAYS_RETENTION.

**Forked from (and inspired by) [https://github.com/grugnog/google-cloud-auto-snapshot](https://github.com/grugnog/google-cloud-auto-snapshot)**
