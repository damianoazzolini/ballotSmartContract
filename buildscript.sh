#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "USE: ./buildscript.sh <account_name> <contract_name> <permission>"
	exit 1
fi

ACCOUNT=$1
CONTRACT=$2
PERMISSION=$3

eosiocpp -o ${CONTRACT}.wast ${CONTRACT}.cpp &&
eosiocpp -g ${CONTRACT}.abi ${CONTRACT}.hpp &&
cleos --wallet-url http://localhost:8899 set contract ${ACCOUNT} ../${CONTRACT} -p $ACCOUNT@$PERMISSION
