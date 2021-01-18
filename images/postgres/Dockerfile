FROM postgres:12

# en_US is already present (default)
RUN localedef -i cs_CZ -c -f UTF-8 cs_CZ.UTF-8 && \
	localedef -i de_DE -c -f UTF-8 de_DE.UTF-8

COPY dropin/init-db.sh /docker-entrypoint-initdb.d/init-db.sh
COPY dropin/backup-db.sh /var/lib/postgresql/
RUN chmod 755 /var/lib/postgresql/backup-db.sh
# this line injects creation & priv grant for the backup folder /var/lib/postgresql/backup
# actual backup must be performed from outside the container with:
# docker exec -it database /var/lib/postgresql/backup-db.sh
RUN sed -i.bak '/#\!\/usr\/bin\/env bash/amkdir -p \/var\/lib\/postgresql\/backup\nchown postgres:postgres \/var\/lib\/postgresql\/backup\n' /usr/local/bin/docker-entrypoint.sh
