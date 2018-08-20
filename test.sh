#!/bin/bash

CONTRACTNAME="ballot"
PROPOSEACTION="propose"
PROPOSEPERMISSION="propose"
VOTEACTION="addvote"
VOTEPERMISSION="vote"
INITACTION="init"
ADDMEMBERACTION="addmember"


nameC="proposal"
titolo="proposta "
descrizione="descrizione proposta "

echo "Numero di votanti (NB: < 5): "
read nVoters

nameV="voter"

while [ $nVoters -gt 0 ] 
do
echo "Inserire indice della proposta da votare (0..n): "
		read index
		vote=$(./encrypt $index)
		let "nVoters=nVoters-1"
		echo $vote
done
