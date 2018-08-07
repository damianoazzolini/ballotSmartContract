pragma solidity ^0.4.22;

// http://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html
// http://remix.ethereum.org/#optimize=true&version=soljson-v0.4.24+commit.e67f0147.js

contract Ballot {
    // dichiaro un tipo di dato Voter che
    // rappresenta un votante
    struct Voter {
        uint weight; // peso del voto, incrementato se si è delegati per votare per un'altra persona
        bool voted; // vero se ha già votato
        uint vote; // indice del candidato votato
        address delegate; // persona delegata a votare, address contiene 20 byte (dimensione di un Ethereum address)
    }
    struct Proposal {
        uint voteCount; // numero di voti accumulati
        bytes32 name; // nome della proposta
    }

    // chi gestisce l'elezione
    address public chairperson;

    // dichiaro una vriabile di stato che salva 
    // una struttura 'Voter' per ogni indirizzo
    // una sorta di tabella chiave valore
    // la definizione di mapping è 
    // mapping(_KeyType => _ValueType)
    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    // Create a new ballot
    // devo passare i valori ["0x1262","0x12","0x123"]
    // msg.sender è una variabile globale che contiene l'indirizzo 
    // di chi ha inviato il messaggio
    /// Create a new ballot to choose one of `proposalNames`.
    constructor(bytes32[] proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Give $(toVoter) the right to vote on this ballot.
    // May only be called by $(chairperson).
    // controllo la correttezza dei parametri con require
    // se require fallisce, la transazione viene annullata
    function giveRightToVote(address voter) public {
        // If the first argument of `require` evaluates
        // to `false`, execution terminates and all
        // changes to the state and to Ether balances
        // are reverted.
        // This used to consume all gas in old EVM versions, but
        // not anymore.
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter $(to).
    function delegate(address to) public {
        // ogni account ha una area di memoria persistente chiamata storage
        // un contratto non può ne leggere nè scrvere aree di storage che non siano le sue
        Voter storage sender = voters[msg.sender]; // assigns reference
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");
        
        // ciclo, da evitare negli smart contract
        // ciclo finché è un account esistente 
        // anche il compilatore lancia warning
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            // trovato un loop, non consentito
            require(to != msg.sender, "Found loop in delegation.");
        }

        // i tipi di dato storage sono riferimenti
        // la linea seguente va di fatto a modificare 
        // voters[msg.sender].voted
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegateTo = voters[to];

        if (delegateTo.voted) {
            // se il  delegato ha già votato
            // aggiorno il numero di voti
            proposals[delegateTo.vote].voteCount += sender.weight;
        }
        else {
            // se non ha votato, incremento il peso
            delegateTo.weight += sender.weight;
        }
    }

    /// Give a single vote to proposal $(toProposal).
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    // la keyword view dice che la funzione non può usare lo
    // storage e non può inviare o rievere ether
    function winningProposal() public view returns (uint8 _winningProposal) {
        uint winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++) {
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
            }
        }
    }

    // chiama winningProposal() per avere l'indice del vincitore e
    // restituire il nome
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}