#!/bin/bash

# script cifratura
echo "---- Building cypher scripts ----"

echo "Building encrypt.c"
gcc -Wall -Wextra encrypt.c -o encrypt -lgmp &&

echo "Building decrypt.c"
gcc -Wall -Wextra decrypt.c -o decrypt -lgmp &&

echo "Building election_result.c"
gcc -Wall -Wextra election_result.c -o election_result -lgmp &&

# compilo lo smart contract e genero RC
echo "---- Compiling Smart Contract ---"
eosiocpp -o ballot.wast ballot.cpp &&
eosiocpp -g ballot.abi ballot.hpp &&
python /home/damiano/Desktop/eos/scripts/abi_to_rc/abi_to_rc.py /home/damiano/Desktop/eos/contracts/ballot/ballot.abi &&

# genero l'account 'ballot' che getisce l'elezione
echo "---- Creating ballot account ----"
cleos --wallet-url http://localhost:8899 create account eosio ballot EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&

# numero di candidati e per ciascuno creo un account
# meno di 5 perché i nomi degli account possono
# contenere solamente .12345a..z
echo "Numero di proposte (NB: < 5): "
read nProposals

nameC="proposal"

while [ $nProposals -gt 0 ] 
do
	cleos --wallet-url http://localhost:8899 create account ballot $nameC$nProposals 				EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&
	echo "Created account:" $nameC$nProposals
done

# numero di votanti e relativi account
echo "Numero di votanti (NB: < 5): "
read nVoters

nameV="voter"

while [ $nVoters -gt 0 ] 
do
	cleos --wallet-url http://localhost:8899 create account ballot $nameV$nVoters				EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&
	echo "Created account:" $nameV$nVoters
done









