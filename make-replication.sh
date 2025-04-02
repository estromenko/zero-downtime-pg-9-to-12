#!/bin/bash

set -x

# Extension installation
docker exec -it zero-downtime-pg-9-to-12-postgres9-1 psql -U postgres -h localhost -c 'CREATE EXTENSION IF NOT EXISTS pglogical'
docker exec -it zero-downtime-pg-9-to-12-postgres12-1 psql -U postgres -h localhost -c 'CREATE EXTENSION IF NOT EXISTS pglogical'


# 9 Postgres setup
docker exec -it zero-downtime-pg-9-to-12-postgres9-1 psql -U postgres -h localhost -c '
  CREATE TABLE IF NOT EXISTS test(
      name text primary key
  );
'
docker exec -it zero-downtime-pg-9-to-12-postgres9-1 psql -U postgres -h localhost -c "
  SELECT pglogical.create_node(
      node_name := 'provider1',
      dsn := 'host=postgres9 port=5432 dbname=postgres password=postgres'
  );
"
docker exec -it zero-downtime-pg-9-to-12-postgres9-1 psql -U postgres -h localhost -c "SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);"


# 12 Postgres setup
docker exec -it zero-downtime-pg-9-to-12-postgres12-1 psql -U postgres -h localhost -c '
  CREATE TABLE IF NOT EXISTS test(
      name text primary key
  );
'
docker exec -it zero-downtime-pg-9-to-12-postgres12-1 psql -U postgres -h localhost -c "
  SELECT pglogical.create_node(
      node_name := 'subscriber1',
      dsn := 'host=postgres12 port=5432 dbname=postgres password=postgres'
  );
"
docker exec -it zero-downtime-pg-9-to-12-postgres12-1 psql -U postgres -h localhost -c "
  SELECT pglogical.create_subscription(
      subscription_name := 'subscription1',
      provider_dsn := 'host=postgres9 port=5432 dbname=postgres password=postgres'
  );
"
docker exec -it zero-downtime-pg-9-to-12-postgres12-1 psql -U postgres -h localhost -c "SELECT pglogical.wait_for_subscription_sync_complete('subscription1');"
