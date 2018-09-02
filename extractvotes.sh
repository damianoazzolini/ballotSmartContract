#!/bin/bash

echo "Compiling code"
gcc -Wall -Wextra election_result.c -o election_result -lgmp
echo "Compiled"

fullTable=$(cleos get table ballot ballot tablevotes)
nlines=$(grep -c -w "vote" <<< "${fullTable}")
votesList=$(cleos get table ballot ballot tablevotes | grep -w "vote" | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ' | tr ',' ' ')
echo $votesList > votes.txt
result=$(./election_result "$votesList")
echo "Number of votes:" $nlines
echo "RESULT"
echo $result
