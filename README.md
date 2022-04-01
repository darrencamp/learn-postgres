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
### ExtendedKey usages
https://www.openssl.org/docs/manmaster/man5/x509v3_config.html

in the openssl cfg file under [v3_req] value extendedKeyUsage set as csv for all valid usages see link above for values

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

refer to script: generate-cert-chain.sh

### pfx file for IIS
refer to:
https://stackoverflow.com/questions/14953132/iis-7-error-a-specified-logon-session-does-not-exist-it-may-already-have-been
https://stackoverflow.com/questions/6307886/how-to-create-pfx-file-from-certificate-and-private-key
https://stackoverflow.com/questions/19552380/no-certificate-matches-private-key-while-generating-p12-file

create a bundle of certificates eg (order may be important)
`cat out/1.crt > bundle.crt`
`cat intermediate/certs/intermediate.crt >> bundle.crt`
`cat root-ca/certs/ca.crt >> bundle.crt`

`openssl pkcs12 -export -out out/1.pfx -inkey out/1.key -in bundle.crt -in out/1.crt`

#### Couldn't get this to work
One of the stackoverflow posts above mentioned converting to pem but couldn't get that to work
`openssl x509 -inform DER -outform PEM -in out/mycontroller.crt -out out/mycontroller.pem`

### windows import certificate
https://superuser.com/questions/1031444/importing-pem-certificates-on-windows-7-on-the-command-line

`certutil –addstore -enterprise –f "Root" <pathtocertificatefile>`

-enterprise = Local Computer store, if require user store remove -enterprise
-f = force overwrite if certificate already exists
For 'Intermediate Certificate Authority' replace "Root" with "CA"
For 'Personal Store' replace "Root" with "My"



# Things I learnt
