#include "ballot.hpp"

// OK TESTED
void ballot::init(account_name appKey, const string& name, const string& description) {
    // require_auth(appKey);
    
    /* First Member Ever Created */
    uint64_t id = accountHash(appKey);

    /* Instantiate the BallotSettings Singleton */
    // BallotSettings(code, _self).set(Settings{appKey}, _self);

    /* Emplce the first member; the creator */
    /* 
    auto creator = Members.emplace(_self, [&](auto& m) {
        m.member_id = id;
        m.account = appKey;
        m.voted = false;
    });
    */
    
    auto current_poll = Polls.find(stringHash(name));
    eosio_assert(current_poll == Polls.end(), "Poll already exists");  
    
    Polls.emplace(_self, [&](auto& p) {
    	p.id = stringHash(name);
    	p.title = name;
    	p.description = description;
    	p.is_active = true;
    });

	// inline action
	// action(permissionlevel, contract_deployer, action, data)
	// action(vector<permission_level>(),N(ballot),N(addmember), make_tuple(appKey,appKey)).send();

    print("Poll initialized ", name);
}

// OK test
void ballot::addmember(account_name account, account_name granter, const string& pollname) {
    // richiedo solo l'autrizzazione del èroprietario del contratto
    // require_auth(granter);
    // require_auth(account);

	// chiave primaria concatenazione account e pollname 
	// per poter avere lo stesso account in due poll
    uint64_t id = accountHash(account+pollname);
    uint64_t granter_id = accountHash(granter);
    
    auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist");
    eosio_assert(current_poll->is_active == true, "Poll is closed");

    auto granter_member = Members.find(granter_id);
    eosio_assert(granter_member != Members.end(), "Granter does not exist");

    auto member = Members.find(id);
    if(member != Members.end())
    	eosio_assert(member->pollname != pollname, "Member already exists for this poll");

    // cerco un componente poi controllo se è già associato alla votazione

    /* Create New Member */
    Members.emplace(_self, [&](auto& m) {
        m.member_id = id;
        m.account = account;
        m.voted = false;
        m.pollname = pollname;
    });

    print("New Member Added: ", name{account}, " for ", pollname);
}

// OK test
void ballot::propose(account_name proposer, const string& title, const string& description, const string& pollname) {
    // require_auth(proposer);

    uint64_t proposer_id = accountHash(proposer);
    uint64_t proposal_id = stringHash(title);
    
    auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist");
    eosio_assert(current_poll->is_active == true, "Poll is closed");

    auto proposer_member = Members.find(proposer_id);
    eosio_assert(proposer_member != Members.end(), "Member does not exist");

    auto prop = Proposals.find(proposal_id);
    eosio_assert(prop == Proposals.end(), "Proposal already exists");
  
    Proposals.emplace(_self, [&](auto& p) {
        p.id = proposal_id;
        p.account = proposer_member->account;
        p.title = title;
        p.description = description;
        p.pollname = pollname;
    });

	print("Created new proposal for ", pollname, " called ", title);
}

// OK test
void ballot::vote(account_name voter, const string& vote, const string& pollname) {
    // require_auth(appKey());
    // require_auth(voter);
    
    auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist");
    eosio_assert(current_poll->is_active == true, "Poll is closed");

    // Find the member 'voter'
    // string proposal = proposal_title+pollname;
    uint64_t voter_id = accountHash(voter);
    // uint64_t proposal_id = stringHash(proposal);

    auto member = Members.find(voter_id);
    eosio_assert(member != Members.end(), "Member does not exist");
    eosio_assert(member->voted == false, "Member has already voted");

    // Find the proposal by 'proposal_id'
    // auto prop = Proposals.find(proposal_id);
    // eosio_assert(prop != Proposals.end(), "Proposal does not exist");

	Members.modify(member, _self, [&](auto& m) {
		m.voted = true;
	});

    // aggiungo un record nella tabella Tablevotes
    Tablevotes.emplace(_self, [&](auto& t) {
        t.id = voter_id;
        t.vote = vote;
        t.pollname = pollname;
    });

    print(name{voter}, " voted in ", pollname);
}

// OK TESTED
void ballot::closepoll(account_name granter, const string& pollname) {
	auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist");
    
    // con false non funziona, con true sì
    // anche se la documentazione dice che la transazione
    // viene abortita se la condizione è vera
    eosio_assert(current_poll->is_active == true, "Poll is already closed");

	Polls.modify(current_poll, _self, [&](auto& p) {
		p.is_active = false;
	});
	
	print("Closed ", pollname);	
}

EOSIO_ABI( ballot, (init)(addmember)(propose)(vote)(closepoll))
