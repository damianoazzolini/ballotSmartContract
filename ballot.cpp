#include "ballot.hpp"

void ballot::init(account_name appKey) {
    require_auth(_self);
    
    /* First Member Ever Created */
    uint64_t id = accountHash(appKey);

    /* Instantiate the BallotSettings Singleton */
    BallotSettings(code, _self).set(Settings{appKey}, _self);

    /* Emplce the first member; the creator */
    /* 
    auto creator = Members.emplace(_self, [&](auto& m) {
        m.member_id = id;
        m.account = appKey;
        m.voted = false;
    });
    */

	// inline action
	// action(permissionlevel, contract_deployer, action, data)
	action(vector<permission_level>(),N(ballot),N(addmember), make_tuple(appKey,appKey)).send();

    print("Contract Initialized", name{appKey});
}

void ballot::addmember(account_name account, account_name granter) {
    // richiedo solo l'autrizzazione del èroprietario del contratto
    require_auth(_self);

    uint64_t id = accountHash(account);
    uint64_t granter_id = accountHash(granter);

    /* Error Handling */
    auto granter_member = Members.find(granter_id);
    eosio_assert(granter_member != Members.end(), "Granter does not exist");

    auto member = Members.find(id);
    eosio_assert(member == Members.end(), "Member already exists!");

    /* Create New Member */
    Members.emplace(_self, [&](auto& m) {
        m.member_id = id;
        m.account = account;
        m.voted = false;
    });

    print("New Member Added: ", name{account});
}

void ballot::propose(account_name proposer, const string& title, const string& description) {
    require_auth(proposer);

    uint64_t proposer_id = accountHash(proposer);
    uint64_t proposal_id = stringHash(title);

    // get 'proposer' member
    auto proposer_member = Members.find(proposer_id);
    eosio_assert(proposer_member != Members.end(), "Member does not exist!");

    // check that proposal is new or modify existing
    auto proposal = Proposals.find(proposal_id);
    eosio_assert(proposal == Proposals.end(), "Proposal already exists!");
  
    print("Creating new proposal");
    Proposals.emplace(_self, [&](auto& p) {
        p.id = proposal_id;
        p.account = proposer_member->account;
        p.title = title;
        p.description = description;
    });

}

// TODO aggiungere metodo per bloccare la votazione
void ballot::vote(account_name voter, const string& proposal_title, const string& vote) {
    // require_auth(appKey());
    require_auth(voter);

    // Find the member 'voter'
    uint64_t voter_id = accountHash(voter);
    uint64_t proposal_id = stringHash(proposal_title);

    auto member = Members.find(voter_id);
    eosio_assert(member != Members.end(), "Member does not exists!");
    eosio_assert(member->voted == true, "Member has already voted");

    // Find the proposal by 'proposal_id'
    auto proposal = Proposals.find(proposal_id);
    eosio_assert(proposal != Proposals.end(), "Proposal does not exist");

	Members.modify(member, _self, [&](auto& m) {
		m.voted = true;
	});

    // aggiungo un record nella tabella Tablevotes
    Tablevotes.emplace(_self, [&](auto& t) {
        t.id = voter_id;
        t.vote = vote;
    });

    print(name{voter}, " voted \n ");
}

EOSIO_ABI( ballot, (init)(addmember)(propose)(vote))
