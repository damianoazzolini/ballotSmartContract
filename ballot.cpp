#include <ballot.hpp> // meglio con " "

void ballot::init(account_name applicationKey) {
	require_auth(_self);
	require_auth(applicationKey);
	unfreezeElection(_self);
}

void ballot::addCandidate(const account_name name, const account_name surname, const string id, const account_name granter) {

}

void ballot::addVoter(const account_name name, const account_name surname, string vote, const account_name granter) {

}

void ballot::freezeElection(const account_name granter) {
	require_auth(granter);
	freezed = true;
}

void ballot::unfreezeElection(const account_name granter) {
	require_auth(granter);
	freezed = false;
}


void ballot::countVotes(const account_name granter) {
	require_auth(granter);
	eosio_assert(freezed == true, "Elezione Terminata");
}
