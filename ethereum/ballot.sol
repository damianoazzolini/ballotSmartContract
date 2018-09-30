pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2; // per usare array di string

// http://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html
// http://remix.ethereum.org/#optimize=true&version=soljson-v0.4.24+commit.e67f0147.js
contract Ballot {
    struct Voter {
        uint weight; // peso del voto
        bool voted; // vero se ha già votato
        bool has_proposed; // vero se ha già proposto
    }
    struct Proposal {
        uint voteCount; // numero di voti accumulati
        bytes32 name; // nome della proposta
    }

    // per proposals non uso mapping perché non riesco a ciclare sui
    // mapping, uso un array
    address public chairperson;
    mapping(address => Voter) public voters;
    bool private is_closed;

    Proposal[] public proposals;

    constructor(string[] proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        voters[chairperson].has_proposed = false;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: stringToBytes32(proposalNames[i]),
                voteCount: 0
            }));
        }

        is_closed = false;
    }

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

    function addProposal(string _name) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.has_proposed, "Candidate hs already proposed.");
        sender.has_proposed = true;
        for(uint i = 0; i < proposals.length; i++) {
            if(proposals[i].name == stringToBytes32(_name)) {
                revert("Proposal already exists");
            }
        }

        proposals.push(Proposal({
            name: stringToBytes32(_name),
            voteCount: 0
        }));
    }

    function vote(string _proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        uint i = 0;

        for(i = 0; i < proposals.length; i++) {
            if(proposals[i].name == stringToBytes32(_proposal)) {
                proposals[i].voteCount ++;
                break;
            }
        }
        require(i != proposals.length,"Proposal does not exists");
    }

    function closeElection() public {
        require(!is_closed,"Already closed");
        require(msg.sender == chairperson,"Only the chairperson can close the election");
        is_closed = true;
    }

    function winningProposal() public view returns (string _winnerName, uint8 _indexWinningProposal, uint _votesCount) {
        require(is_closed,"Pool is not closed");
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
