#!/bin/bash

CONTRACTNAME="ballot"
VOTEPERMISSION="vote"
VOTEACTION="vote"
GRANTER="ballot"

echo "Insert pollname "
read pollname

echo "Proposals list"
echo "-----"
cleos get table ballot ballot proposals | grep 'title\|index\|'$pollname''
echo "-----"

echo "Insert voter name"
read votername

echo "Insert proposal index to vote "
read proposal

vote=$(./encrypt $proposal)

echo "Encrypted " $vote

cleos push action $CONTRACTNAME $VOTEACTION '["'"$votername"'","'"$GRANTER"'","'"$vote"'","'"$pollname"'"]' -p $votername@$VOTEPERMISSION

if [ $? -ne 0 ]; then
    echo "Erorr in voting action"
else
    echo "Vote successful"
fi
