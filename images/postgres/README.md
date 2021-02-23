# PostgreSQL image
Image built atop official [postgres image](https://hub.docker.com/_/postgres) image.
Official image does not support other collation than en_US, this image supports a bit more - mainly it support cs_CZ and de_DE collations.
It also forces you to mount db init scripts from the outside. This is an inconvenience when you just need to create user and a database... so we handle that too.

## Image versioning
Naming scheme is pretty simple: **bcv-postgres:POSTGRES_VERSION-rIMAGE_VERSION**.
- Image name is **bcv-postgres**.
- **POSTGRESQL_VERSION** is a version of PostgreSQL in the image.
- **IMAGE_VERSION** is an image release version written as a serial number, starting at 0. When images have the same PostgreSQL versions but different image versions it means there were some changes in the image itself (setup scripts, etc.) but application itself did not change.

Example
```
bcv-postgres:12-r0     // first release of PostgreSQL 12 image
bcv-postgres:12-r37    // thirty seventh release of PostgreSQL 12 image
bcv-postgres:678-r0    // first release of PostgreSQL 678 image
```

## Building
Simply cd to the directory which contains the Dockerfile and issue `docker build -t <image tag here> ./`.

The build process:
1. Pulls official **postgres:XXX** image.
1. Sets up more locales.
1. Sets up a database init script.

No security hardening or engine sizing is performed.

## Use
- Use in the same way as [original image](https://hub.docker.com/_/postgres).
- Set up following **mandatory** variables.
  - POSTGRES_PASSWORD_FILE
  - DB_USER
  - DB_USER_PASSWORD_FILE
  - DB_NAME
  - DB_COLLATION

### Example
```
docker create \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres.passwd \
  -e DB_USER='myuser' \
  -e DB_USER_PASSWORD_FILE=/run/secrets/dbuser.passwd \
  -e DB_NAME='mydatabase' \
  -e DB_COLLATION='cs_CZ.utf8' \
  -v /somepath/postgres.passwd:/run/secrets/postgres.passwd \
  -v /somepath/dbuser.passwd:/run/secrets/dbuser.passwd \
  -- bcv-postgres
```
This will create a container with four databases: `postgres`, `template0`, `template1` and `mydatabase`. Database `mydatabase` will have `cs_CZ.utf8` collation, other databases will have a default one (`en_US.utf8`).

There will be two users in the database: `postgres` and `myuser`. Their passwords will be set according to contents of their password files.

## Environment variables
You can use all variables the official image supports. Plus, there are additional variables:
- **DB_USER** - Login of the database user you will use (it will be different than `postgres`).
- **DB_USER_PASSWORD_FILE** - Path to the file with a password for DB_USER.
- **DB_NAME** - Name of the database the init script will try to create.
- **DB_COLLATION** - Collation of the DB_NAME database.
- **DB_ENCRYPT_SYMKEY_FILE** - Location of symmetric key for backup encryption.
- **DB_ENCRYPT_BACKUP** - Flag that turns on/off the backup encryption. Format `true`/`false`.

### Supported collations
Presently, image supports those collations.
- en_US.utf8
- cs_CZ.utf8
- de_DE.utf8

### Backups
Container can make a persistent backup of the database, using `pg_dump` with highest compression internally.
To make a backup of the database, simly run `docker exec -it database /var/lib/postgresql/backup-db.sh` from outside the container.
Ordinary, unencrypted, backup have suffix `.gz`.
For details, see [dropin/backup-db.sh](dropin/backup-db.sh).

The container can be instructed to create encrypted backups.
See DB_ENCRYPT_SYMKEY_FILE and DB_ENCRYPT_BACKUP environment variables.
Purpose of encrypted backups is that they can be safely shipped off-machine to another storage.
They are protected with AES-256-CBC, with random salt and PBKDF2 key generation function.
Encrypted backups have the suffix `.e` at the end of the file.
After decryption, proceed the same way as you would with unencrypted backup.
- Example encryption:
  ```
  openssl enc -e -aes-256-cbc -salt -pbkdf2 -pass file:/run/secrets/enc_backup_symkey.key -in mydatabase.sql.gz -out mydatabase.sql.gz.e
  ```
- Example decryption:
  ```
  openssl enc -d -aes-256-cbc -pbkdf2 -pass file:/run/secrets/enc_backup_symkey.key -in mydatabase.sql.gz.e -out mydatabase.sql.gz
  ```

## Mounted files and volumes
- Mandatory
  - File containing DB_USER's password
    - This password protects accest to the DB_USER database account.
    - Without this file mounted, the init script will not create any extra user. Container init may fail.
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./dbuser.pwfile
          target: /run/secrets/dbuser.pwfile
          read_only: true
      ```
- Optional
  - Directory which will hold database datafiles.
    - There are your persistent data in this directory.
    - Without this directory mounted, you can run the container. But you will lose data on container rm...
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./somedir
          target: /var/lib/postgresql/data
          read_only: false
      ```
  - Directory which will hold database backups.
    - There are your backups in the directory.
    - Without this directory mounted, container will not store your database backups persistently.
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./somedir
          target: /var/lib/postgresql/backup
          read_only: false
      ```
