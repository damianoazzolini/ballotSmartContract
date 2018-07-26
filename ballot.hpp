#include <eosiolib/eosio.hpp>
#include <eosiolib/print.hpp>
#include <string>

using namespace eosio;
using std::string;

//classe che eredita da eosio::controact
class ballot : public contract {
	public:
		// costruttore
		ballot(account_name self) : contract(self) {}
	
		// @abi action
		void hello(account_name account);
		
		// @abi action
		void create(const account_name account, const string username, const string bio, uint32_t age);
		// voglio salvare i dati
		// creo delle tabelle

	private:
		// @abi table profiles i64
		// i primi 64 bit sono usati come indice
		struct profile {
			account_name account; // o uint64_t, stessa cosa typedef
			string username;
			string bio;
			uint32_t age;
			
			account_name primary_key() const {
				return account;
			}

			EOSLIB_SERIALIZE(profile,(account)(username)(bio)(age))
		};

		typedef eosio::multi_index<N(profile), profile> profile_table;

};

EOSIO_ABI(ballot, (hello)(create))
