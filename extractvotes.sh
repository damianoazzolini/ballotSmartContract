#!/bin/bash

fullTable=$(cleos --wallet-url http://localhost:8899 get table ballot ballot tablevotes)
nlines=$(grep -c -w "vote" <<< "${fullTable}")
votesList=$(cleos --wallet-url http://localhost:8899 get table ballot ballot tablevotes | grep -w "vote" | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ' | tr ',' '\n')
# ./decrypt "$votesList"
echo $votesList
echo $nlines
