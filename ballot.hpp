#include <eosiolib/eosio.hpp>
// #include <eosiolib/singleton.hpp>
#include <eosiolib/crypto.h>

using namespace std;
using namespace eosio;

class ballot : public contract {
public:
    // Constuct an instance of both the Members multi_index
    // and the Proposals multi_index with in the context of the
    // contracts scope itself

    ballot(account_name _self) :
          contract(_self),
          Members(_self, _self),
          Tablevotes(_self, _self),
          Proposals(_self, _self),
          Polls(_self,_self) {}

	// ballot(account_name _self):contract(_self) {};

    // static constexpr uint64_t code = N(ballot);

    // @abi action
    void init(account_name granter, const string& pollname, const string& description);

    // @abi action
    void addmember(account_name account, account_name granter, const string& pollname);

    // @abi action
    void propose(account_name proposer, const string& title, const string& description, const string& pollname, uint64_t index);

    // @abi action
    void vote(account_name voter, account_name granter, const string& vote, const string& pollname);

    // @abi action
    void closepoll(account_name granter, const string& pollname);

    // @abi action
    void setwinner(account_name granter, const string& pollname, uint64_t winner_proposal_index);

    // @abi action
    void cleartables(account_name granter, const string& pollname, const string& tablename);

private:
	// @abi table polls i64
	struct Poll {
		uint64_t id;
		string title;
		string description;
		bool is_active = true;
		bool is_winner_set = false;
		uint64_t winner_proposal_index;
        // TODO
        // add time created_at;
        // nel cpp
        // x.created_at = now();

		auto primary_key() const { return id; }

		EOSLIB_SERIALIZE(Poll, (id)(title)(description)(is_active)(is_winner_set)(winner_proposal_index))
	};

    // @abi table members i64
    struct Member {
        uint64_t member_id;
        account_name account;
        bool voted = false;
        string pollname;

        uint64_t primary_key() const { return member_id; }

        EOSLIB_SERIALIZE(Member, (member_id)(account)(voted)(pollname))
    };

    // @abi table proposals i64
    struct Proposal {
        uint64_t id;
        account_name account;
        string title;
        string description;
		string pollname;
		uint64_t index;

		// ho un id ed un index perché tutte le proposte sono salvate nella stessa
		// tabella quindi hanno tutte un id diverso. Index invece rappresenta
		// l'indice della proposta all'interno della votazione corrente

        // TODO
        // add time created_at;

        uint64_t primary_key() const { return id; }

        EOSLIB_SERIALIZE(Proposal, (id)(account)(title)(description)(pollname)(index))
    };

	/*
    struct Settings {
        account_name            appKey;

        uint64_t primary_key() const { return 0; }
        EOSLIB_SERIALIZE( Settings, (appKey) )
    };
    */

    // creo una tabella per contenere solo i voti
    // @abi table tablevotes i64
    struct Tablevote {
    	uint64_t id;
    	string vote;
    	string pollname;
        // TODO
        // add time created_at;

    	uint64_t primary_key() const { return id; }

    	EOSLIB_SERIALIZE(Tablevote, (id)(vote)(pollname))
    };

	multi_index<N(tablevotes), Tablevote> Tablevotes;
    multi_index<N(members), Member> Members;
    multi_index<N(proposals), Proposal> Proposals;
    multi_index<N(polls), Poll> Polls;

    // typedef singleton<N(settings), Settings>  BallotSettings;

    inline static uint64_t stringHash( const string& strkey ){
        return std::hash<string>{}(strkey);
    }

    inline static uint64_t accountHash( const account_name& key ){
        return std::hash<uint64_t>{}(key);
    }

};
