#!/bin/sh

while getopts s:m: flag; do
    case "${flag}" in
        s)
            SERVICE=${OPTARG};;
        m)
            MODE=${OPTARG};;
        *)
            echo "Invalid arguments (${flag}). Usage: log -service [service name] -mode [stderr|stdout]"
            exit 1 ;;
    esac
done

FILE="/var/log/supervisor/$SERVICE.$MODE.log"

if [ -f "$FILE" ]; then
    echo "Reading file: ${FILE}" && tail -f -n 100 "$FILE"
else
    echo "Log file: ${FILE} does not exist."
fi