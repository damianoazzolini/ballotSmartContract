#include <eosiolib/eosio.hpp>
#include <eosiolib/singleton.hpp>
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
          Proposals(_self, _self) {}

    static constexpr uint64_t code = N(ballot);

    // @abi action
    void init(account_name appKey);

    // @abi action
    void addmember(account_name account, account_name granter);

    // @abi action
    void propose(account_name proposer, const string& title, const string& description);

    // @abi action
    void vote(account_name voter, const string& proposal_title, const string& vote);


private:

    // @abi table members i64
    struct Member {
        uint64_t member_id;
        account_name account;
        bool voted = false;

        uint64_t primary_key() const { return member_id; }
        
        EOSLIB_SERIALIZE(Member, (member_id)(account))
    };

    // @abi table proposals i64
    struct Proposal {
        uint64_t     id;
        account_name account;
        string       title;
        string       description;

        uint64_t primary_key() const { return id; }
        
        EOSLIB_SERIALIZE(Proposal, (id)(account)(title)(description))
    };

    // @abi table settings i64
    struct Settings {
        account_name            appKey;

        uint64_t primary_key() const { return 0; }
        EOSLIB_SERIALIZE( Settings, (appKey) )
    };
    
    // creo una tabella per contenere solo i voti
    // @abi table tablevotes i64
    struct Tablevote {
    	uint64_t id; 
    	string vote;
    	
    	uint64_t primary_key() const { return id; }
    	
    	EOSLIB_SERIALIZE(Tablevote, (id)(vote))
    };

	multi_index<N(tablevotes), Tablevote> Tablevotes;
    multi_index<N(members), Member> Members;
    multi_index<N(proposals), Proposal> Proposals;

    typedef singleton<N(settings), Settings>  BallotSettings;


    inline static uint64_t stringHash( const string& strkey ){
        return std::hash<string>{}(strkey);
    }

    inline static uint64_t accountHash( const account_name& key ){
        return std::hash<uint64_t>{}(key);
    }

};
