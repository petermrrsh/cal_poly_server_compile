#!/usr/bin/env bash

# Edit these for personal use
server="unix2.csc.calpoly.edu"
user="pkmarsh"
password="*************"
#password=$(cat pwd.txt)

print_usage() {
    echo '*'
    echo '* USAGE'
    echo '* ./compile_on_server.sh <c file> -options'
    echo '* '
    echo '* OPTIONS'
    echo '* -o <output_file>      Specify an output file name (defaults to "output")'
    echo '* -e <error_file>       Specify an error file name (defaults to "error")'
    echo '* '
    echo '* EXAMPLE'
    echo '* ./compile_on_server.sh hello_world.c -o out.txt -e err.txt'
    echo '* '
}

output_file=""
error_file=""
c_file=""

count=0
while [[ $# > 0 ]]
do
key="$1"
case $key in
    --help)
        print_usage
        exit 0
    ;;
    -o)
        if [[ $2 != "" ]]
          then
            output_file=$2
            shift
          else
            echo "Error: must specify an output file after -o"
            print_usage
            exit 1
        fi
    ;;
    -e)
        if [[ $2 != "" ]]
          then
            error_file=$2
            shift
          else
            echo "Error: must specify an error file after -e"
            print_usage
            exit 1
        fi
    ;;
    *)
        if [[ $c_file == "" ]]
        then
            c_file=$key
          else
            echo "Error: invalid number of arguments"
            print_usage
            exit 1
        fi
        let "count++"
    ;;
esac
shift # past argument or value
done

if [[ $count != 1 ]]; then
  echo "Error: incorrect number of args"
  print_usage
  exit 1
fi

if [[ $output_file == "" ]]; then output_file="output"; fi
if [[ $error_file == "" ]]; then error_file="error"; fi

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
server_cmd "./a.out 1> $output_file 2> $error_file"
server_scp_from $output_file .
server_scp_from $error_file .