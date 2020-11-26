FROM postgres:12

# en_US is already present (default)
RUN localedef -i cs_CZ -c -f UTF-8 cs_CZ.UTF-8 && \
	localedef -i de_DE -c -f UTF-8 de_DE.UTF-8

COPY dropin/init-db.sh /docker-entrypoint-initdb.d/init-db.sh
