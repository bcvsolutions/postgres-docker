#!/bin/bash

# This creates a database with an user as an owner.
# You must specify a collation.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ${DB_USER} PASSWORD '$(cat "$DB_USER_PASSWORD_FILE")';
    CREATE DATABASE ${DB_NAME} OWNER ${DB_USER} ENCODING 'UTF8' LC_COLLATE = '${DB_COLLATION}' LC_CTYPE = '${DB_COLLATION}' template 'template0';
EOSQL
