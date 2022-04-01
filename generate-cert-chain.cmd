
ECHO off
FOR %%C in (root-ca,intermediate) DO (

  rd /s /q %%C
  mkdir %%C
  pushd %%C
  mkdir certs crl newcerts private
  popd

  echo 1000 > %%C/serial
  type nul >> %%C/index.txt 
  type nul >> %%C/index.txt.attr

(
echo [ ca ]
echo default_ca = CA_default
echo [ CA_default ]
echo dir            = '%%C'                    # Where everything is kept
echo certs          = $dir/certs               # Where the issued certs are kept
echo crl_dir        = $dir/crl                 # Where the issued crl are kept
echo database       = $dir/index.txt           # database index file.
echo new_certs_dir  = $dir/newcerts            # default place for new certs.
echo certificate    = $dir/cacert.pem          # The CA certificate
echo serial         = $dir/serial              # The current serial number
echo crl            = $dir/crl.pem             # The current CRL
echo private_key    = $dir/private/ca.key.pem  # The private key
echo RANDFILE       = $dir/.rnd                # private random number file
echo nameopt        = default_ca
echo certopt        = default_ca
echo policy         = policy_match
echo default_days   = 365
echo default_md     = sha256
echo: 
echo [ policy_match ]
echo countryName            = optional
echo stateOrProvinceName    = optional
echo organizationName       = optional
echo organizationalUnitName = optional
echo commonName             = supplied
echo emailAddress           = optional
echo: 
echo [req]
echo req_extensions = v3_req
echo distinguished_name = req_distinguished_name
echo: 
echo [req_distinguished_name]
echo: 
echo [v3_req]
echo basicConstraints = CA:TRUE
) > %%C/openssl.conf
)

openssl genrsa -out root-ca/private/ca.key 2048
openssl req -config root-ca/openssl.conf -new -x509 -days 3650 -key root-ca/private/ca.key -sha256 -extensions v3_req -out root-ca/certs/ca.crt -subj "/CN=Root-ca"

openssl genrsa -out intermediate/private/intermediate.key 2048
openssl req -config intermediate/openssl.conf -sha256 -new -key intermediate/private/intermediate.key -out intermediate/certs/intermediate.csr -subj "/CN=Interm."
openssl ca -batch -config root-ca/openssl.conf -keyfile root-ca/private/ca.key -cert root-ca/certs/ca.crt -extensions v3_req -notext -md sha256 -in intermediate/certs/intermediate.csr -out intermediate/certs/intermediate.crt

del Certificates.zip
7z a -tzip Certificates.zip .\root-ca\certs\ca.crt .\intermediate\certs\intermediate.crt

FOR %%B in (9185-8631-5153-9680-0658-2498-78,0126-0664-2317-7703-5382-3634-07) DO (
    del out/*%%B

(
echo [req]
echo distinguished_name = req_distinguished_name
echo req_extensions = v3_req
echo prompt = no
echo: 
echo [req_distinguished_name]
echo C = AU
echo ST = SA
echo L = Newton
echo O = Coding Intent
echo OU = ATeam
echo CN = MyController-%%B
echo: 
echo [v3_req]
echo keyUsage = keyEncipherment, digitalSignature
echo extendedKeyUsage = clientAuth, serverAuth
echo basicConstraints = CA:FALSE
echo subjectKeyIdentifier = hash
echo subjectAltName = @alt_names
echo [alt_names]
echo DNS.1 = MyController
echo DNS.2 = localhost
echo IP.1 = 10.252.255.253
echo IP.2 = 10.252.255.254) > out/openssl-%%B.conf

    openssl req -new -keyout out/%%B.key -out out/%%B.request -days 365 -nodes -config out/openssl-%%B.conf -newkey rsa:2048
    openssl ca -batch -config root-ca/openssl.conf -extfile out/openssl-%%B.conf -extensions v3_req -keyfile intermediate/private/intermediate.key -cert intermediate/certs/intermediate.crt -out out/%%B.crt -infiles out/%%B.request

    type .\out\%%B.crt > .\out\%%B-bundle.crt
    type .\intermediate\certs\intermediate.crt >> .\out\%%B-bundle.crt
    type .\root-ca\certs\ca.crt >> .\out\%%B-bundle.crt

    openssl pkcs12 -export -passout pass: -out out/%%B.pfx -inkey out/%%B.key -in out/%%B-bundle.crt -in out/%%B.crt
    7z a -tzip Certificates.zip .\out\%%B.crt .\out\%%B.key .\out\%%B.pfx 
)

