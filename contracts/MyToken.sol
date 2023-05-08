// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./SafeMath.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract MyToken is IERC20 {
    using SafeMath for uint256;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 value);
    event TokensSold(address indexed seller, uint256 amount, uint256 value);

    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _tokenTotalSupply;
    uint256 internal _currentPrice;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupplyAmount_,
        uint256 initialPrice_
    ) {
        _tokenName = name_;
        _tokenSymbol = symbol_;
        _tokenDecimals = decimals_;
        _tokenTotalSupply = initialSupplyAmount_;
        _balances[msg.sender] = initialSupplyAmount_;
        _currentPrice = initialPrice_;
    }

    function name() public view returns (string memory) {
        return _tokenName;
    }

    function symbol() public view returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() public view returns (uint8) {
        return _tokenDecimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenTotalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(
            amount <= _balances[msg.sender],
            "Insufficient amount of tokens"
        );
        require(address(0) != recipient, "Unable to send tokens to nowhere");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(
            amount <= _balances[msg.sender],
            "Insufficient amount of tokens"
        );
        require(address(0) != spender, "Address can't be zero");

        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(
            amount <= _allowances[sender][msg.sender],
            "Insufficient amount of tokens"
        );
        require(address(0) != recipient, "Unable to send tokens to nowhere");

        _balances[recipient] = _balances[recipient].add(amount);
        _balances[sender] = _balances[sender].sub(amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(
            amount
        );

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function price() external view returns (uint256) {
        return _currentPrice;
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Amount of ether sent must be > 0");

        uint256 tokensAmount = msg.value.div(_currentPrice);
        _balances[msg.sender] = _balances[msg.sender].add(tokensAmount);
        _tokenTotalSupply = _tokenTotalSupply.add(tokensAmount);

        payable(address(this)).transfer(msg.value);

        emit TokensPurchased(msg.sender, tokensAmount, msg.value);
    }

    function sellTokens(uint256 tokensAmount) public {
        require(tokensAmount > 0, "Number of tokens must be > 0");
        require(tokensAmount <= _balances[msg.sender], "Insufficient tokens");

        _balances[msg.sender] = _balances[msg.sender].sub(tokensAmount);
        _tokenTotalSupply = _tokenTotalSupply.sub(tokensAmount);

        uint256 etherValue = tokensAmount.mul(_currentPrice).div(1 ether);

        payable(msg.sender).transfer(etherValue);

        emit TokensSold(msg.sender, tokensAmount, etherValue);
    }

    // receive() external payable {}
}
