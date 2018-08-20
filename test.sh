#!/bin/bash

echo "Numero di proposte: "
read nCandidates

name="proposal"

while [ $nCandidates -gt 0 ] 
do
	echo $name$nCandidates "crated"
	let "nCandidates=nCandidates-1"
done
