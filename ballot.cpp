#include "ballot.hpp"

// OK TESTED
void ballot::init(account_name granter, const string& pollname, const string& description) {
    require_auth(granter);
    
    auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll == Polls.end(), "Poll already exists");  
    
    Polls.emplace(_self, [&](auto& p) {
    	p.id = stringHash(pollname);
    	p.title = pollname;
    	p.description = description;
    	p.is_active = true;
    });
    print("Poll initialized ", pollname);
    
    uint64_t id = stringHash(to_string(granter)+pollname);
    /*
    Dovrei inserire il granter come nuovo member senza inline action perché
    addmember richiede che il granter esista già
    */
    Members.emplace(_self, [&](auto& m) {
        m.member_id = id;
        m.account = granter;
        m.voted = false;
        m.pollname = pollname;
    });

	// inline action
	// action(permissionlevel, contract_deployer, action, data)
	// action(vector<permission_level>(),N(ballot),N(addmember), make_tuple(appKey,appKey)).send();

    print("\nGranter ", name{granter}, " created for ", pollname);
}

// OK test
void ballot::addmember(account_name account, account_name granter, const string& pollname) {
    require_auth(granter);
    // require_auth(account);

	// chiave primaria concatenazione account e pollname 
	// per poter avere lo stesso account in due poll
	// devo convertire in stringhe poi riconvertire in uint64_t 
	// per evitare overflow facendo la somma account+stringHash(pollname)
    uint64_t id = stringHash(to_string(account)+pollname);
    uint64_t granter_id = stringHash(to_string(granter)+pollname);
    
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

    uint64_t proposer_id = stringHash(to_string(proposer)+pollname);
    uint64_t proposal_id = stringHash(title+pollname);
    
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
        p.index = this->index_proposal;
    });

	print("Created new proposal for ", pollname, " called ", title, " index ", this->index_proposal);
	
	this->index_proposal++;
}

// OK test
void ballot::vote(account_name voter, const string& vote, const string& pollname) {
    // require_auth(voter);
    
    auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist");
    eosio_assert(current_poll->is_active == true, "Poll is closed");

    uint64_t voter_id = stringHash(to_string(voter)+pollname);

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
	require_auth(granter);
	
	uint64_t granter_id = stringHash(to_string(granter)+pollname);
	auto granter_member = Members.find(granter_id);
    eosio_assert(granter_member != Members.end(), "Granter does not exist");
	
	auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist");
    
    eosio_assert(current_poll->is_active == true, "Poll is already closed");

	Polls.modify(current_poll, _self, [&](auto& p) {
		p.is_active = false;
	});
	
	// conto i voti
	uint64_t vote_number = 0;
	for(auto vote_iterator = Tablevotes.begin(); vote_iterator != Tablevotes.end(); vote_iterator++) {
	if(vote_iterator->pollname == pollname)
		vote_number++;
	}
	
	print("Closed ", pollname, ". Number of votes: ", vote_number);	
}

void ballot::setwinner(account_name granter, const string& pollname, uint64_t winner_proposal_index) {
	require_auth(granter);
	
	uint64_t granter_id = stringHash(to_string(granter)+pollname);
	auto granter_member = Members.find(granter_id);
    eosio_assert(granter_member != Members.end(), "Granter does not exist");

	auto current_poll = Polls.find(stringHash(pollname));
    eosio_assert(current_poll != Polls.end(), "Poll does not exist"); 
    
    eosio_assert(current_poll->is_winner_set == false, "Winner already set");
    eosio_assert(current_poll->is_active == true, "Poll stil open");
    
    // TODO
    // controllo se la proposta con quell'indice esiste per quel poll
    /*
    auto proposal_itr;
    for(proposal_itr = Proposals.begin(); proposal_itr != Proposals.end(); proposal_itr++) {
    	if((proposal_itr->index == winner_proposal_index) && (proposal_itr->pollname == pollname))
    		break;
    }
    
    
    eosio_assert(proposal_itr != Proposals.end(), "Proposal with selected index does not exist for this poll");
    */
    
    Polls.modify(current_poll, _self, [&](auto& p) {
		p.is_winner_set = true;
		p.winner_proposal_index = winner_proposal_index;
	});
	
	print("Winner set for poll ", pollname);	
}

EOSIO_ABI( ballot, (init)(addmember)(propose)(vote)(closepoll)(setwinner))
