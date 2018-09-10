#!/bin/bash
CONTRACTNAME="ballot"
PROPOSEPERMISSION="propose"
PROPOSEACTION="propose"
GRANTER="ballot"

echo "Insert proposer"
read proposer

echo "Insert title"
read title

echo "Insert description"
read description

echo "Insert pollname"
read pollname

echo "Insert index"
read index

cleos push action $CONTRACTNAME $PROPOSEACTION '["'"$proposer"'","'"$title"'","'"$description"'","'"$pollname"'","'"$index"'"]' -p $proposer@$PROPOSEPERMISSION

if [ $? -ne 0 ]; then
    echo "Erorr in init propose"
else
    echo "Init successful"
fi
