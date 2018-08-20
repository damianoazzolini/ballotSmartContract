#!/bin/bash

CONTRACTNAME="ballot"
PROPOSEACTION="propose"
PROPOSEPERMISSION="propose"
VOTEACTION="addvote"
VOTEPERMISSION="vote"
INITACTION="init"
ADDMEMBERACTION="addmember"
TABLEVOTES="tablevotes"

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

# inzializzo il contratto
cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $INITACTION '["ballot"]' -p ballot@active 

# numero di candidati e per ciascuno creo un account
# meno di 5 perché i nomi degli account possono
# contenere solamente .12345a..z
# per ciascuna proposta creo un permesso
# 'propose' e assegno al permesso l'azione 'propose'
echo "Numero di proposte (NB: < 5): "
read nProposals

nameC="proposal"
titolo="proposta "
descrizione="descrizione proposta "

while [ $nProposals -gt 0 ] 
do
	# creo account
	cleos --wallet-url http://localhost:8899 create account ballot $nameC$nProposals 				EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&
	
	# creo il permesso
	cleos --wallet-url http://localhost:8899 set account permission $nameC$nProposals $PROPOSEPERMISSION EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 "active" -p $nameC$nProposals@active &&
	
	# associo il pemesso all'azione
	cleos --wallet-url http://localhost:8899 set action permission $nameC$nProposals $CONTRACTNAME $PROPOSEACTION $PROPOSEPERMISSION &&
	
	# aggiungo il componente
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $ADDMEMBERACTION '["'"$nameC$nProposals"'","ballot",1,false]' -p ballot@active &&
	
	# carico la proposta
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $PROPOSEACTION '["'"$nameC$nProposals"'","'"$titolo$nProposals"'","'"$descrizione$nProposals"'"]' -p $nameC$nProposals@$PROPOSEPERMISSION &&
	
	echo "Created proposal:" $nameC$nProposals
	let "nProposals=nProposals-1"
done

# numero di votanti e relativi account
# creo permesso 'vote' relativo all'azione 'addvote'
echo "Numero di votanti (NB: < 5): "
read nVoters

nameV="voter"

while [ $nVoters -gt 0 ] 
do
	# creo account
	cleos --wallet-url http://localhost:8899 create account ballot $nameV$nVoters				EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&
	
	# creo permesso
	cleos --wallet-url http://localhost:8899 set account permission $nameV$nVoters $VOTEPERMISSION EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 "active" -p $nameV$nVoters@active &&
	
	# associo il permesso all'azione
	cleos --wallet-url http://localhost:8899 set action permission $nameV$nVoters $CONTRACTNAME $VOTEACTION $VOTEPERMISSION &&
	
	# aggiungo l'account
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $ADDMEMBERACTION '["'"$nameV$nVoters"'","ballot",1,false]' -p ballot@active &&
	
	# simulo una votazione
	# ottengo l'elenco delle proposte
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $ADDMEMBERACTION '["'"$nameV$nVoters"'","ballot",1,false]' -p ballot@active &&
	
	echo "---- ELENCO PROPOSTE ----"
		cleos --wallet-url http://localhost:8899 get table ballot ballot proposals | grep title
		echo "Inserire indice della proposta da votare (0..n): "
		read index
		vote=$(./encrypt $index)
	
	
		if [ $? -eq 0 ]; then
			# TODO sistemare, automatizzare
			echo "Inserire nome della proposta da votare (0..n): "
			read name
			
			cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $VOTEACTION '["'"$nameV$nVoters"'","'"$name"'","'"$vote"'"]' -p $nameV$nVoters@$VOTEPERMISSION 
		else
			echo "ERRORE NELLA CIFRATURA, VOTO NON CARICATO"
		fi
	let "nVoters=nVoters-1"
done

# effettuo il conteggio
# TODO blocco la votazione
 
cleos --wallet-url http://localhost:8899 get table ballot ballot tablevotes | grep -w "vote" | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ' | tr -d ',' > votes.txt

./election_result






