# Learning postgres + replication + docker

## Postgresql with replication
Some ideas borrowed from:
https://github.com/DanielDent/docker-postgres-replication

and https://medium.com/swlh/postgresql-replication-with-docker-c6a904becf77


### reloading changes to pg_hba.conf
reload pg_hba.conf
SELECT pg_reload_conf();

load current pg_hba.conf
table pg_hba_file_rules ;

## Docker

docker network create pg-replication


## Certificates
### Generating keys (self-signed)
config sample here : https://docs.scylladb.com/operating-scylla/security/generate-certificate/
https://stackoverflow.com/questions/26759550/how-to-create-own-self-signed-root-certificate-and-intermediate-ca-to-be-importe
https://stackoverflow.com/questions/30977264/subject-alternative-name-not-present-in-certificate

`openssl genrsa -out caserver.key 4096`
`openssl req -x509 -new -nodes -key caserver.key -days 3650 -config server.cfg -out caserver.pem`
`openssl genrsa -out server.key 4096`
`openssl req -new -key server.key -out server.csr -config server.cfg`
`openssl x509 -req -in server.csr -CA caserver.pem -CAkey caserver.key -CAcreateserial  -out server.crt -days 365`

gives
server.key
server.crt
caserver.pem

### windows import certificate
https://superuser.com/questions/1031444/importing-pem-certificates-on-windows-7-on-the-command-line

`certutil –addstore -enterprise –f "Root" <pathtocertificatefile>`

-enterprise = Local Computer store, if require user store remove -enterprise
-f = force overwrite if certificate already exists
For 'Intermediate Certificate Authority' replace "Root" with "CA"
For 'Personal Store' replace "Root" with "My"

# Things I learnt