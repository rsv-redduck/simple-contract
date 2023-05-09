// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./MyToken.sol";
import "./SafeMath.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract VotingToken is MyToken {
    using SafeMath for uint256;

    event VotingStarted(
        uint256 startTime,
        uint256 endTime,
        uint256 votingNumber
    );
    event VoteEnded(uint256 result);

    mapping(uint256 => mapping(uint256 => uint256)) private _voteCount;
    mapping(uint256 => mapping(address => bool)) private _hasVoted;
    uint256[] private _votePrices;

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
        require(!_hasVoted[_votingNumber][msg.sender], "You already voted");
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

        _voteCount[_votingNumber][price_] = _voteCount[_votingNumber][price_].add(_balances[msg.sender]);
        _votePrices.push(price_);
        _hasVoted[_votingNumber][msg.sender] = true;

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
        _votingNumber++;

        // Clear the vote data befor the next voting
        delete _votePrices;

        emit VotingStarted(
            _votingStartedTime,
            _votingStartedTime.add(_timeToVote),
            _votingNumber
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
            if (_voteCount[_votingNumber][_votePrices[i]] > winningVoteCount) {
                winningPrice = _votePrices[i];
                winningVoteCount = _voteCount[_votingNumber][_votePrices[i]];
            }
        }

        _votingStartedTime = 0;
        require(winningPrice > 0, "The token cannot be free");
        _currentPrice = winningPrice;

        emit VoteEnded(winningPrice);

        return true;
    }
}
