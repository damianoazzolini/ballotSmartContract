pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2; // per usare array di string

// http://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html
// http://remix.ethereum.org/#optimize=true&version=soljson-v0.4.24+commit.e67f0147.js
contract Ballot {
    struct Voter {
        uint weight; // peso del voto, incrementato se si è delegati per votare per un'altra persona
        bool voted; // vero se ha già votato
        uint vote; // indice del candidato votato
    }
    struct Proposal {
        uint voteCount; // numero di voti accumulati
        bytes32 name; // nome della proposta
    }

    address public chairperson;
    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    constructor(string[] proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            bytes32 temp = stringToBytes32(proposalNames[i]);
            proposals.push(Proposal({
                name: temp,
                voteCount: 0
            }));
        }
    }

    // from stackoverflow
    // converts string to byte32
    function stringToBytes32(string memory source) pure private returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    // converts bytes32 to string
    function bytes32ToString(bytes32 x) pure private returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }


    function giveRightToVote(address voter) public {
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

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // chontrollo che eista prima di effettuare l'operazione
        // senza controllo l'operazione fallirebbe comunque ma non
        // riesco ad eseguirla perché dice
        // "gas required exceeds allowance or always failing transaction"
        if(proposal >= proposals.length) {
            revert("Proposal does not exists");
        }
        proposals[proposal].voteCount += sender.weight;

    }

    function winningProposal() public view returns (string _winnerName, uint8 _indexWinningProposal, uint _votesCount) {
        uint winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++) {
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _indexWinningProposal = prop;
                _votesCount = winningVoteCount;
                _winnerName = bytes32ToString(proposals[prop].name);
            }
        }
    }
}
