// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin's upgradeable contracts and security modules
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract Governance is OwnableUpgradeable, UUPSUpgradeable {
    using SafeMathUpgradeable for uint256;

    // Governance proposal structure
    struct Proposal {
        uint256 id;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => bool) voters;
    }

    // State variables
    ERC20VotesUpgradeable public votingToken; // Token used for voting
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    // Events
    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 id);

    // Initialization function
    function initialize(ERC20VotesUpgradeable _votingToken) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        votingToken = _votingToken;
    }

    // Authorization for UUPSUpgradeable
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // Function to create a proposal
    function createProposal(string calldata description) external onlyOwner {
        uint256 proposalId = proposalCount;
        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.description = description;
        proposalCount = proposalCount.add(1);

        emit ProposalCreated(proposalId, description);
    }

    // Function to vote on a proposal
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.voters[msg.sender], "Already voted");
        require(votingToken.balanceOf(msg.sender) > 0, "No voting power");

        if (support) {
            proposal.forVotes = proposal.forVotes.add(votingToken.balanceOf(msg.sender));
        } else {
            proposal.againstVotes = proposal.againstVotes.add(votingToken.balanceOf(msg.sender));
        }
        proposal.voters[msg.sender] = true;

        emit Voted(proposalId, msg.sender, support);
    }

    // Function to execute a proposal if it passes
    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.forVotes > proposal.againstVotes, "Proposal not passed");

        // Execute proposal logic here
        // For example: change a contract state, transfer funds, etc.

        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }
}

