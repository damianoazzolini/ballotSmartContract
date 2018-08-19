#!/bin/bash

fullTable=$(cat testGrep.txt)
nlines=$(grep -c "vote" <<< "${fullTable}")
votesList=$(cat testGrep.txt | grep "vote" | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ')
./decrypt "$votesList"