FROM debian:bullseye

RUN apt-get update \
  && apt-get install -y ca-certificates \
  && echo 'deb [trusted=yes] https://apt-archive.postgresql.org/pub/repos/apt bionic-pgdg main' > /etc/apt/sources.list.d/pgdp.list \
  && apt-get update --allow-insecure-repositories \
  && apt-get install -y postgresql-9.5 postgresql-9.5-pglogical

USER postgres

RUN chown -R postgres:postgres /var/lib/postgresql \
  && chmod 0700 /var/lib/postgresql

COPY postgresql.conf /etc/postgresql/postgresql.conf

ENV PGDATA=/var/lib/postgresql/9.5/main

CMD [ "/usr/lib/postgresql/9.5/bin/postgres", "-c", "config_file=/etc/postgresql/postgresql.conf" ]
