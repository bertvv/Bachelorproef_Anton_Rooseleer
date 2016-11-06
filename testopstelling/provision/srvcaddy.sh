#! /bin/bash
#
#

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables

# Color definitions
readonly reset='\e[0m'
readonly black='\e[0;30m'
readonly red='\e[0;31m'
readonly green='\e[0;32m'
readonly yellow='\e[0;33m'
readonly blue='\e[0;34m'
readonly purple='\e[0;35m'
readonly cyan='\e[0;36m'
readonly white='\e[0;37m'

ip=192.168.56.52
download_dir=/tmp/caddy
provisioning_files=/vagrant/provision/files
systemd_service_file=/lib/systemd/system/caddy.service

#}}}

#{{{ Helper functions

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}### %s${reset}\n" "${*}"
}

# Usage: files_differ FILE1 FILE2
#
# Tests whether the two specified files have different content
#
# Returns with exit status 0 if the files are identical, a nonzero exit status
# if they differ
files_differ() {
  local -r checksum1=$(md5sum "${1}" | cut -c 1-32)
  local -r checksum2=$(md5sum "${2}" | cut -c 1-32)

  [ "${checksum1}" != "${checksum2}" ]
}

#}}}

# Script proper

info 'Installing Caddy'

if [ ! -x /usr/local/bin/caddy ]; then
  # Synchronize package database
  apt-get update

  # Download Caddy installation files 
  wget -O /tmp/caddy.tar.gz 'https://caddyserver.com/download/build?os=linux&arch=amd64&features='

  # Unzip installation archive in temporary directory
  mkdir "${download_dir}"
  pushd "${download_dir}"
  tar xf /tmp/caddy.tar.gz
  popd
  cp "${download_dir}/caddy" /usr/local/bin

  # Cleanup installation files
  rm -rf /tmp/caddy*
else
  info '  -> Caddy already installed, skipping'
fi

if files_differ "${systemd_service_file}" "${provisioning_files}/caddy.service"; then
  info 'Copying Systemd service file'
  cp "${provisioning_files}/caddy.service" "${systemd_service_file}"
  systemctl daemon-reload
fi

if [ ! -d /var/www ]; then
  info 'Creating document root'
  mkdir /var/www
  chown -R root:www-data /var/www
  chmod 755 /var/www
fi

if [ ! -f /var/www/index.html ]; then
  info 'Copying test homepage'
  cp "${provisioning_files}/index.html" /var/www
fi

info 'Configuration'

if [ ! -d /etc/caddy ]; then
  info '  -> Creating configuration directory'
  mkdir /etc/caddy
fi

cat > /etc/caddy/Caddyfile << _EOF_
https://${ip} {
  root /var/www
  log stdout
  errors stderr
  tls self_signed
}
_EOF_

info 'Starting service'
systemctl start caddy
systemctl enable caddy
