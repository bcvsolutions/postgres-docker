#!/bin/bash
now=$(date "+%Y-%m-%d_%H-%M-%S")

if [ "$DB_ENCRYPT_BACKUP" == "true" ] && [ -f "$DB_ENCRYPT_SYMKEY_FILE" ]; then
  pg_dump -Z 9 -U postgres --dbname="$DB_NAME" --create | \
    openssl enc -e -aes-256-cbc -salt -pbkdf2 \
      -pass file:"$DB_ENCRYPT_SYMKEY_FILE" \
      -out /var/lib/postgresql/backup/"${DB_NAME}-${now}.sql.gz.e"
  # to decrypt, use something like:
  # openssl enc -d -aes-256-cbc -pbkdf2 -in mydatabase-2021-02-22_15-00-45.sql.gz.e -out mydatabase.sql.gz -pass file:/run/secrets/enc_backup_symkey.key
  # then, recover the database using the mydatabase.sql.gz as usual
else
  pg_dump -Z 9 -U postgres --dbname="$DB_NAME" --create -f /var/lib/postgresql/backup/"${DB_NAME}-${now}.sql.gz"
fi
