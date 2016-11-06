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
#}}}

# Script proper

info "Installing Caddy"

if [ ! -x /usr/local/bin/caddy ]; then
  apt-get update
  wget -O /tmp/caddy.tar.gz 'https://caddyserver.com/download/build?os=linux&arch=amd64&features='
  mkdir "${download_dir}"
  pushd "${download_dir}"
  tar xf /tmp/caddy.tar.gz
  popd
  cp "${download_dir}/caddy" /usr/local/bin

  info "Installing Systemd service file"

  cp "${download_dir}/init/linux-systemd/caddy.service" /lib/systemd/system
  systemctl daemon-reload
else
  info "  -> Caddy already installed, skipping"
fi

if [ ! -d /var/www ]; then
  info " Creating document root"
  mkdir /var/www
  chown -R root:www-data /var/www
  chmod 755 /var/www
fi

info 'Configuration'

if [ ! -d /etc/caddy ]; then
  info "  -> Creating configuration directory"
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

info "Starting service"
systemctl start caddy
systemctl enable caddy
