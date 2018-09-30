#!/bin/bash

CONTRACTNAME="ballot"
PROPOSEACTION="propose"
PROPOSEPERMISSION="propose"
VOTEACTION="vote"
GRANTER="ballot"
VOTERNAME="ballot"
POLLNAME="votazione"

function stressAccountCreation {
    echo "Insert numbers of accounts to be created "
    read nAccounts
    counter=1
    testaccount="test"

    while [ $nAccounts -gt 1 ]; do
        cleos create account eosio $testaccount$counter EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9 EOS6SSHcCaBrmQLPUgUthQ3mD13NktVzPerkJEDSLRDbn8N7jNNG9
        sleep 0.2
        let nAccounts=nAccounts-1
        let counter=counter+1
    done

    echo "Done stressing"
}

echo "STRESS TEST"
stressAccountCreation
