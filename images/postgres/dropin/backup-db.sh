#!/bin/bash
now=$(date "+%Y-%m-%d_%H-%M-%S")
pg_dump -Z 9 -U postgres --dbname="$DB_NAME" --create -f /var/lib/postgresql/backup/"${DB_NAME}-${now}.sql.gz"
