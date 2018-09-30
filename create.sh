#!/bin/bash

CONTRACTNAME="ballot"
PROPOSEACTION="propose"
PROPOSEPERMISSION="propose"
VOTEACTION="vote"
VOTEPERMISSION="vote"
INITACTION="init"
ADDMEMBERACTION="addmember"
TABLEVOTES="tablevotes"
CLOSEPOLLACTION="closepoll"
CONTRACTGRANTER="ballot"
VOTEFIELD="vote"
BALLOTDIRECTORY="ballotSmartContract"

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
# python /home/damiano/Desktop/eos/scripts/abi_to_rc/abi_to_rc.py /home/damiano/Desktop/eos/contracts/ballot/ballot.abi &&

# carico il contratto
echo "---- Uploading contract ----"
cleos --wallet-url http://localhost:8899 set contract $CONTRACTGRANTER ../$CONTRACTNAME -p $CONTRACTGRANTER@active

# genero l'account 'ballot' che getisce l'elezione
echo "---- Creating ballot account ----"
cleos --wallet-url http://localhost:8899 create account eosio $CONTRACTGRANTER EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9

# inzializzo il contratto
echo "Nome della votazione: "
read POLLNAME
echo "Descrizione della votazione"
read DESCRIPTION


cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $INITACTION '["'"$CONTRACTGRANTER"'","'"$POLLNAME"'","'"$DESCRIPTION"'"]' -p $CONTRACTGRANTER@active

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
	cleos --wallet-url http://localhost:8899 create account ballot $nameC$nProposals EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&

	# creo il permesso
	cleos --wallet-url http://localhost:8899 set account permission $nameC$nProposals $PROPOSEPERMISSION EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 "active" -p $nameC$nProposals@active &&

	# associo il pemesso all'azione
	cleos --wallet-url http://localhost:8899 set action permission $nameC$nProposals $CONTRACTNAME $PROPOSEACTION $PROPOSEPERMISSION &&

	# aggiungo il componente
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $ADDMEMBERACTION '["'"$nameC$nProposals"'","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active &&

	# carico la proposta
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $PROPOSEACTION '["'"$nameC$nProposals"'","'"$titolo$nProposals"'","'"$descrizione$nProposals"'","'"$POLLNAME"'","'"$nProposals"'"]' -p $nameC$nProposals@$PROPOSEPERMISSION &&

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
	cleos --wallet-url http://localhost:8899 create account ballot $nameV$nVoters EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 &&

	# creo permesso
	cleos --wallet-url http://localhost:8899 set account permission $nameV$nVoters $VOTEPERMISSION EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 "active" -p $nameV$nVoters@active &&

	# associo il permesso all'azione
	cleos --wallet-url http://localhost:8899 set action permission $nameV$nVoters $CONTRACTNAME $VOTEACTION $VOTEPERMISSION &&

	# aggiungo l'account
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $ADDMEMBERACTION '["'"$nameC$nProposals"'","'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]' -p $CONTRACTGRANTER@active &&

	# simulo votazione
	echo "---- ELENCO PROPOSTE ----"
		cleos --wallet-url http://localhost:8899 get table ballot ballot proposals | grep title
		echo "Inserire indice della proposta da votare (0..n): "
		read index
		vote=$(./encrypt $index)


		if [ $? -eq 0 ]; then
			echo "Inserire nome della proposta da votare (0..n): "
			read name

			cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $VOTEACTION '["'"$nameV$nVoters"'","'"$vote"'","'"$POLLNAME"'"]' -p $nameV$nVoters@$VOTEPERMISSION
		else
			echo "ERRORE NELLA CIFRATURA, VOTO NON CARICATO"
		fi
	let "nVoters=nVoters-1"
done

# effettuo il conteggio

echo "Bloccare la votazione (1 sì, 0 no)?"
read stop

if [ $stop -eq 1 ]; then
	cleos --wallet-url http://localhost:8899 push action $CONTRACTNAME $CLOSEPOLLACTION '["'"$CONTRACTGRANTER"'","'"$POLLNAME"'"]'
	echo "Elezione terminata"
else
	echo "Conteggio ad elezione ancora attiva"
fi

cleos --wallet-url http://localhost:8899 get table ballot ballot tablevotes | grep -w -A1 -B1 $POLLNAME | grep -w $VOTEFIELD | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ' | tr -d ',' > votes.txt

# cleos --wallet-url http://localhost:8899 get table ballot ballot tablevotes | grep -w "vote" | sed 's/"vote": "//g' | sed 's/"//g' | tr -d ' ' | tr -d ',' > votes.txt

./election_result
