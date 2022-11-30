#!/bin/sh

# https://stackoverflow.com/a/1710543
# shellcheck disable=SC2155

set -e
set -u

readonly curdir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly password='CzgiqOUso2k'
readonly certs_root_dir="$curdir/tls-gen/basic"
readonly certs_result_dir="$certs_root_dir/result"
readonly ca_cert_pem="$certs_result_dir/ca_certificate.pem"

readonly rmq_certs="$curdir/certs"
readonly ca_cert_der="$rmq_certs/ca_certificate.der"
readonly client_truststore="$rmq_certs/client-truststore.pkcs12"

# This generates the CA, as well as server/client certs for rmq0
make -C "$certs_root_dir" 'CN=rmq0'

# This usese the CA above and generates the server/client certs for rmq1
make -C "$certs_root_dir" 'CN=rmq1' gen-server
make -C "$certs_root_dir" 'CN=rmq1' gen-client

rm -vf "$client_truststore"

openssl x509 -outform der -in "$ca_cert_pem" -out "$ca_cert_der"

keytool -genkey -dname "cn=client-truststore" -alias "client-truststore" -keyalg RSA -keystore "$client_truststore" -storetype pkcs12 -keypass "$password" -storepass "$password"

keytool -noprompt -import -keystore "$client_truststore" -storepass "$password" -trustcacerts -file "$ca_cert_der" -alias tls-gen_basic_ca

for RMQ in rmq0 rmq1
do
    client_cert="$certs_result_dir/client_${RMQ}_certificate.pem"
    client_key="$certs_result_dir/client_${RMQ}_key.pem"
    client_pfx="$rmq_certs/$RMQ/client_${RMQ}.pfx"
    client_keystore="$rmq_certs/$RMQ/client-keystore.pkcs12"

    rm -vf "$client_keystore"

    keytool -genkey -dname "cn=client-keystore" -alias client-keystore -keyalg RSA -keystore "$client_keystore" -storetype pkcs12 -keypass "$password" -storepass "$password"

    cp -vf "$certs_result_dir"/ca_certificate.pem "$rmq_certs/$RMQ/"
    cp -vf "$certs_result_dir"/*"$RMQ"*.pem "$rmq_certs/$RMQ/"

    openssl pkcs12 -export -out "$client_pfx" -passout "pass:$password" -inkey "$client_key" -in "$client_cert"

    keytool -importkeystore -srcalias 1 -srckeystore "$client_pfx" -srcstoretype pkcs12 -srcstorepass "$password" -destkeystore "$client_keystore" -destkeypass "$password" -deststorepass "$password" -deststoretype pkcs12 -destalias "client_${RMQ}"
done
