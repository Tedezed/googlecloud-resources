#!/bin/bash
set -e

# By: Juan Manuel Torres (Tedezed)

# Example execution: bash sql_migration.bash mysql-demo europe-west1 europe-west1-b

NAME_SQL_MACHINE=$1
REGION=$2
ZONE=$3

ID_OPERATION="sqlm-$RANDOM"

echo "[INFO] Show instances"
gcloud sql instances list
gcloud sql instances describe $NAME_SQL_MACHINE > $NAME_SQL_MACHINE.yaml

echo "[INFO] Create backup"
gcloud sql backups create --async -i $NAME_SQL_MACHINE --description "SQL Migration $1 to $1-$2 - $ID_OPERATION"

sleep 5
ID_BACKUP=$(gcloud sql backups list -i $NAME_SQL_MACHINE | head -2 | grep -v ID | awk '{ print $1 }')
STATUS="0"
echo "[INFO] Waiting for the backup end"
while [ "$STATUS" == "0" ]; do
	sleep 3
	STATUS_BACKUP=$(gcloud sql backups list -i $1 | grep $ID_BACKUP | awk '{print $4}')
	if [ "$STATUS_BACKUP" == "SUCCESSFUL" ]; then
		STATUS="1"
	fi
	gcloud sql backups list -i $NAME_SQL_MACHINE
done
sleep 3

echo "[INFO] Show backups"
gcloud sql backups describe -i $NAME_SQL_MACHINE $ID_BACKUP | grep "description\|id\|status"
gcloud sql backups list -i $NAME_SQL_MACHINE | head -2 | grep -v ID | awk '{ print $1 }'

echo "[INFO] Create new instance"
gcloud sql instances create $1-$ID_OPERATION --region $2 --gce-zone $3 $(python read_yaml.py $NAME_SQL_MACHINE.yaml)
gcloud sql instances list

echo "[INFO] Restore backup"
gcloud sql backups restore $ID_BACKUP --restore-instance=$1-$ID_OPERATION --backup-instance $1

echo "
[END] Need stop instance $NAME_SQL_MACHINE in old region/zone if you not want duplicate database/servers
"