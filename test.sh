#!/bin/bash

NOME="votazionea"
VOTEFIELD="vote"

cat prova.txt | grep -w -A1 -B1 $NOME | grep -w $VOTEFIELD | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ' | tr -d ','
