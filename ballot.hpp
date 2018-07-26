#include <eosiolib/eosio.hpp>
#include <eosiolib/print.hpp>
#include <string>

using namespace eosio;
using namespace std;

//classe che eredita da eosio::contract
class ballot : public contract {
	public:
		// costruttore
		ballot(account_name self) : contract(self) {}

		// @abi action
		void init(account_name applicationKey);
		// inizializzo il voto con la chiave "master"
		
		// @abi action
		void addCandidate(
			const account_name name, 
			const account_name surname, 
			const string id, 
			const account_name granter);
		// creo un candidato
		// granter è colui che inserisce il nome, deve essere validato

		// @abi action
		void addVoter(
			const account_name name,
			const account_name surname,
			string vote,
			const account_name granter
		);
		// creo un votante

		// @abi action
		void freezeElection(const account_name granter);

		// @abi action
		void unfreezeElection(const account_name granter);

		// @abi action
		bool isFreezed(const account_name granter);

		// @abi action
		void countVotes(const account_name granter); 

		// come faccio ad autenticare chu crea l'elezione?
		// devo fare in modo che abbia una chiave nascosta 
		// che deve caricare ogni volta che effettua un'azione
		// posso farlo con un wallet diverso
		// wallet master -> solo chiavi di chi ha tutti i permessi
		// wallet votanti -> tutte le chiavi dei vontanti
		// il master è sempre bloccato e la password la sa solo uno

	private:
		// boolean col quale controllo tutte le elezioni
		// TODO permettere che si possa modificare solamente
		// una volta (una volta terminata l'elezione non può
		// più essere riaperta)
		static bool freezed = false;

		// @abi table voters i64
		struct Voter {
			string name;
			string surname;
			uint64_t id;
			uint64_t vote; // cotiene l'id del candidato votato

			auto primary_key() const { return id; }
			EOSLIB_SERIALIZE(Voter, (name)(surname)(id)(vote))
		};

		// @abi table candidates i64
		struct Candidate {
			string name;
			string surname;
			uint64_t id;

			auto primary_key() const { return id; }
			EOSLIB_SERIALIZE(Candidate, (name)(surname)(id))
		};

		typedef eosio::multi_index<N(voters), Voter> voters_table;
		typedef eosio::multi_index<N(candidates), Candidate> candidates_table;
};

EOSIO_ABI(ballot, (init)(addCandidate)(addVoter)(freezeElection)(unfreezeElection)(isFreezed)(countVotes))
