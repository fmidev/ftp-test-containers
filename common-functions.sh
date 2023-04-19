#!/usr/bin/env bash
#
# Common bash functions used for testing FTP, FPTS and SFTP.
#
# For configuration reference, see:
#
# * docker-compose.yaml
# * https://hub.docker.com/r/fauria/vsftpd
# * https://hub.docker.com/r/delfer/alpine-ftp-server
# * https://hub.docker.com/r/atmoz/sftp
#
# @author mikko.parviainen@fmi.fi, 2023
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

SCRIPT_BASE_DIR="$(dirname "${BASH_SOURCE[0]}")"
LFTP_CONFIGURATION_FILE="${HOME}/.lftprc"

function cleanup() {
  cd "${SCRIPT_BASE_DIR}"
  rm --force --verbose \
    cert/localhost.{crt,key} \
    upload/{image.jpg,text.txt} \
    "${LFTP_CONFIGURATION_FILE}"

  # lftp_configuration_backup_file is populated  as a side-effect in generate_lftp_client_configuration_for_ftps()
  lftp_backup_file="${lftp_configuration_backup_file:-}"
  if [[ -n "${lftp_backup_file}" ]]; then
    mv --verbose "${lftp_backup_file}" "${LFTP_CONFIGURATION_FILE}"
    echo "Restored lftp configuration file from ${lftp_backup_file} to ${LFTP_CONFIGURATION_FILE}"
  fi
}

# Generates a private key and a self-signed certificate for FTPS
function generate_private_key_and_certificate_for_ftps() {
  mkdir --parents --verbose cert
  rm --force --verbose cert/localhost.{crt,key}
  openssl req -x509 -out cert/localhost.crt -keyout cert/localhost.key \
    -newkey rsa:2048 -nodes -sha256 \
    -subj '/CN=localhost' -extensions EXT -config <( \
     printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
}

# Side-effect: populates a variable lftp_configuration_file for recovering the previous lftp configuration (or empty)
function generate_lftp_client_configuration_for_ftps() {
  # Intentionally not declaring lftp_configuration_backup_file local to enable access from cleanup()
  lftp_configuration_backup_file=""

  if [[ -f "${LFTP_CONFIGURATION_FILE}" ]]; then
    lftp_configuration_backup_file="$(mktemp -t ".lftprc.backup.XXXXXX")"
    cp --verbose --archive "${LFTP_CONFIGURATION_FILE}" "${lftp_configuration_backup_file}"
    echo "Created a backup of current lftp configuration file to ${lftp_configuration_backup_file}"
  fi

  cat << EOF > "${LFTP_CONFIGURATION_FILE}"
set ftp:ssl-auth TLS
set ftp:ssl-force true
set ftp:ssl-protect-list yes
set ftp:ssl-protect-data yes
set ftp:ssl-protect-fxp yes
set ssl:verify-certificate no
set ssl:verify-certificate no
set ftp:passive-mode yes
debug 1
EOF
}

function generate_test_files() {
  mkdir --mode=777 --parents --verbose upload
  convert -size 32x32 xc:white upload/image.jpg
  echo "foobar" > upload/text.txt
}

function remove_previously_known_localhost_sftp_host_key() {
  ssh-keygen -R "[localhost]:2222" || \
    echo "warning: host key file is probably missing"
}

function start_ftp_servers() {
  docker compose up --abort-on-container-exit
}

function stop_ftp_servers() {
  docker compose down
}
