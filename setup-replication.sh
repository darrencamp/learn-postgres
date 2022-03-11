#!/bin/bash

if [ "x$REPLICATE_FROM" == "x" ]; then

cat >> ${PGDATA}/postgresql.conf <<EOF
wal_level = hot_standby
max_wal_senders = $PG_MAX_WAL_SENDERS
hot_standby = on
EOF

else

cat >> ${PGDATA}/postgresql.auto.conf <<EOF
primary_conninfo = 'host=${REPLICATE_FROM} port=5432 user=${POSTGRES_USER} password=${POSTGRES_PASSWORD}'
primary_slot_name = 'replication_slot_slave1'
restore_command = 'cp /var/lib/postgresql/data/pg_wal/%f "%p"'
EOF


fi