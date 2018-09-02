#!/bin/bash

cleos create account eosio ballot EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot voter1 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot voter2 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot voter3 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot voter4 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot voter5 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot proposer1 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

cleos create account ballot proposer2 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 1

echo "Created accounts ballot, voter1..5, proposer1..2"

cleos set account permission voter1 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p voter1@active
sleep 0.5
cleos set action permission voter1 ballot vote vote
sleep 1

cleos set account permission voter2 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p voter2@active
sleep 1
cleos set action permission voter2 ballot vote vote
sleep 1

cleos set account permission voter3 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p voter3@active
sleep 1
cleos set action permission voter3 ballot vote vote
sleep 1

cleos set account permission voter4 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p voter4@active
sleep 1
cleos set action permission voter4 ballot vote vote
sleep 1

cleos set account permission voter5 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p voter5@active
sleep 1
cleos set action permission voter5 ballot vote vote
sleep 1
echo "Set permissions *vote* for accounts voter1..5"

cleos set account permission proposer1 propose EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p proposer1@active
sleep 1
cleos set action permission proposer1 ballot propose propose
sleep 1

cleos set account permission proposer2 propose EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p proposer2@active
sleep 1
cleos set action permission proposer2 ballot propose propose
sleep 1
echo "Set permissions *propose* for accounts proposer1..2"

echo "--- FINISH ---"
