#!/usr/bin/env bash

# Edit these for personal use
server="unix2.csc.calpoly.edu"
user="pkmarsh"
password="**************"

print_usage() {
    echo '*'
    echo '* USAGE'
    echo '* ./compile_on_server.sh <c file>'
    echo '* '
}

if (( $# != 1 ))
then
    print_usage
    exit 1
fi

c_file=$1

# server_cmd <command to run on the server...>
server_cmd() {
    ./server_login.expect -cmd $server $user $password $*
}

# server_scp_to <local file> <server destination path>
server_scp_to() {
    ./server_login.expect -to $server $user $password $1 $2
}

# server_scp_to <server file> <local destination path>
server_scp_from() {
    ./server_login.expect -from $server $user $password $1 $2
}

server_scp_to $c_file .
server_cmd gcc $c_file
server_cmd ./a.out
server_scp_from output .
server_scp_from error .