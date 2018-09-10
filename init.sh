#!/bin/bash

ADDMEMBERACTION="addmember"
CONTRACTNAME="ballot"
INITACTION="init"

echo "Insert granter name"
read CONTRACTGRANTER

echo "Insert pollname"
read POLLNAME

echo "Insert description"
read DESCRIPTION

cleos push action $CONTRACTNAME $INITACTION '["'"$CONTRACTGRANTER"'","'"$POLLNAME"'","'"$DESCRIPTION"'"]' -p $CONTRACTGRANTER@active

if [ $? -ne 0 ]; then
    echo "Erorr in init action"
else
    echo "Init successful"
fi

# add all the accounts
cleos push action $CONTRACTNAME $ADDMEMBERACTION '["votante1","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

cleos push action $CONTRACTNAME $ADDMEMBERACTION '["votante2","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

cleos push action $CONTRACTNAME $ADDMEMBERACTION '["votante3","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

cleos push action $CONTRACTNAME $ADDMEMBERACTION '["votante4","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

cleos push action $CONTRACTNAME $ADDMEMBERACTION '["votante5","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

cleos push action $CONTRACTNAME $ADDMEMBERACTION '["candidato1","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

cleos push action $CONTRACTNAME $ADDMEMBERACTION '["candidato2","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active
sleep .5

if [ $? -ne 0 ]; then
    echo "Erorr in adding members action"
else
    echo "Members added successfully"
fi
