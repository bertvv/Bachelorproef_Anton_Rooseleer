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

apt-get update
ulimit -n 8192
cd /vagrant
chmod a=rx caddy
touch Caddyfile
ss -tlnp
ss -ulnp
echo  'https://192.168.56.52  ' > Caddyfile
echo  'log stdout ' >> Caddyfile
echo  'errors stderr ' >> Caddyfile
echo  'tls self_signed ' >> Caddyfile
echo  'tls email  ' >> Caddyfile
ls
./caddy -quic


