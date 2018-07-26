#include <ballot.hpp>

void ballot::hello(account_name account) {
	print("Hello ", name{account});
}

void ballot::create(const account_name account, const string username, const string bio, uint32_t age) {
	require_auth(account); //controllare anche require_auth2
	// controllo se non esiste già
	// contracte code e scope come parametri
	profile_table profile(_self,_self);

	auto itr = profile.find(account); // restituisce un iterator

	// uso assert che automaticamente cancella la transazione e rollback di tutto
	eosio_assert(itr == profile.end(), "Account already has a profile");

	// funzione lambda
	// & prende tutte le variabili definite nello scope e 
	// le passa per riferimento
	profile.emplace(account, [&](auto& p) {
		p.account = account;
		p.username = username;
		p.bio = bio;
		p.age = age;
	}); 

	print(name{account}, "profile created");
}
