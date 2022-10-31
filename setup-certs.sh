#!/bin/sh

# https://stackoverflow.com/a/1710543
# shellcheck disable=SC2155

set -e
set -u

readonly curdir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly certs_root_dir="$curdir/tls-gen/basic"
readonly certs_result_dir="$certs_root_dir/result"
readonly ca_cert_pem="$certs_result_dir/ca_certificate.pem"

readonly rmq_certs="$curdir/certs"

# This generates the CA, as well as server/client certs for rmq0
make -C "$certs_root_dir" 'CN=rmq0'

# This uses the CA above and generates the EXPIRED server/client certs for rmq1
faketime 'last Friday 5 pm' make -C "$certs_root_dir" 'CN=rmq1' DAYS_OF_VALIDITY=1 gen-server
faketime 'last Friday 5 pm' make -C "$certs_root_dir" 'CN=rmq1' DAYS_OF_VALIDITY=1 gen-client

cp -vf "$ca_cert_pem" "$rmq_certs"

for RMQ in rmq0 rmq1
do
    cp -vf "$certs_result_dir"/*"$RMQ"*.pem "$rmq_certs/$RMQ/"
done
