#!/bin/bash

cleos create account eosio ballot EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot votante1 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot votante2 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot votante3 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot votante4 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot votante5 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot candidato1 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

cleos create account ballot candidato2 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
sleep 0.5

echo "Created accounts ballot, votante1..5, candidato1..2"

cleos set account permission votante1 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p votante1@active
sleep 0.5
cleos set action permission votante1 ballot vote vote
sleep 0.5

cleos set account permission votante2 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p votante2@active
sleep 0.5
cleos set action permission votante2 ballot vote vote
sleep 0.5

cleos set account permission votante3 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p votante3@active
sleep 0.5
cleos set action permission votante3 ballot vote vote
sleep 0.5

cleos set account permission votante4 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p votante4@active
sleep 0.5
cleos set action permission votante4 ballot vote vote
sleep 0.5

cleos set account permission votante5 vote EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p votante5@active
sleep 0.5
cleos set action permission votante5 ballot vote vote
sleep 0.5
echo "Set permissions *vote* for accounts votante1..5"

cleos set account permission candidato1 propose EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p candidato1@active
sleep 0.5
cleos set action permission candidato1 ballot propose propose
sleep 0.5

cleos set account permission candidato2 propose EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 active -p candidato2@active
sleep 0.5
cleos set action permission candidato2 ballot propose propose
sleep 0.5
echo "Set permissions *propose* for accounts candidato1..2"

echo "--- FINISH ---"
