// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./MyToken.sol";
import "./SafeMath.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract VotingToken is MyToken {
    using SafeMath for uint256;

    event VotingStarted(uint256 startTime, uint256 endTime);
    event VoteEnded(uint256 result);

    mapping(uint256 => uint256) private _voteCount;
    mapping(address => bool) private _hasVoted;
    uint256[] private _votePrices;
    address[] private _registeredVoters;

    uint256 private _votingNumber = 0;
    uint256 private _timeToVote = 1 days;
    uint256 private _votingStartedTime = 0;
    uint256 private _minTokenAmount = 5;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupplyAmount_,
        uint256 initialPrice_,
        uint256 minTokenAmount_
    ) MyToken(name_, symbol_, decimals_, initialSupplyAmount_, initialPrice_) {
        _minTokenAmount = minTokenAmount_;
    }

    function vote(uint256 price_) external returns (bool) {
        require(!_hasVoted[msg.sender], "You already voted");
        require(
            (_tokenTotalSupply.mul(_minTokenAmount).div(10000)) <=
                _balances[msg.sender],
            "Insufficient voting power"
        );
        require(
            _votingStartedTime > 0 &&
                block.timestamp <= _votingStartedTime.add(_timeToVote),
            "Voting not started or ended"
        );

        _voteCount[price_] = _voteCount[price_].add(_balances[msg.sender]);
        _votePrices.push(price_);
        _hasVoted[msg.sender] = true;
        _registeredVoters.push(msg.sender);

        return true;
    }

    function startVoting() public returns (bool) {
        require(0 == _votingStartedTime, "Voting has already started");
        require(
            (_tokenTotalSupply.mul(_minTokenAmount).div(10000)) <=
                _balances[msg.sender],
            "Insufficient voting power"
        );

        _votingStartedTime = block.timestamp;

        // Clear the vote data befor the next voting
        for (uint256 i = 0; i < _votePrices.length; i++) {
            delete _voteCount[_votePrices[i]];
        }
        delete _votePrices;

        for (uint256 i = 0; i < _registeredVoters.length; i++) {
            delete _hasVoted[_registeredVoters[i]];
        }
        delete _registeredVoters;

        emit VotingStarted(
            _votingStartedTime,
            _votingStartedTime.add(_timeToVote)
        );

        return true;
    }

    function endVoting() public returns (bool) {
        require(
            _votingStartedTime > 0 &&
                block.timestamp > _votingStartedTime.add(_timeToVote),
            "Voting not started or finished"
        );

        uint256 winningPrice = 0;
        uint256 winningVoteCount = 0;

        for (uint256 i = 0; i < _votePrices.length; i++) {
            if (_voteCount[_votePrices[i]] > winningVoteCount) {
                winningPrice = _votePrices[i];
                winningVoteCount = _voteCount[_votePrices[i]];
            }
        }

        _votingStartedTime = 0;
        require(winningPrice > 0, "The token cannot be free");
        _currentPrice = winningPrice;

        emit VoteEnded(winningPrice);

        return true;
    }
}
