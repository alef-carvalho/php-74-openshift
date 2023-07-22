#!/bin/sh

while getopts n: flag

do
        case "${flag}" in
                n) service=${OPTARG}
                         ;;
                *) echo "Invalid option: -$flag" ;;
        esac
done

command="/var/log/supervisor/${service}.err.log";

tail -n 100 "$command"