// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract SavingsVault {


    // Ether balances
    mapping(address => uint256) private ethBalances;

    // Token balances
    // user => tokenAddress => balance
    mapping(address => mapping(address => uint256)) private tokenBalances;

    // EVENTS
    
    event EtherDeposited(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed user, uint256 amount);

    event TokenDeposited(address indexed user, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed user, address indexed token, uint256 amount);

    // ETHER FUNCTIONS

    function depositEther() external payable {
        require(msg.value > 0, "Must send Ether");

        ethBalances[msg.sender] += msg.value;

        emit EtherDeposited(msg.sender, msg.value);
    }

function withdrawEther(uint256 amount) external {
    require(ethBalances[msg.sender] >= amount, "Insufficient balance");

    // Effects first (important for security)
    ethBalances[msg.sender] -= amount;

    // Interaction
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Ether transfer failed");

    emit EtherWithdrawn(msg.sender, amount);
}


    function getEtherBalance(address user) external view returns (uint256) {
        return ethBalances[user];
    }

    // ERC20 FUNCTIONS

    function depositToken(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer tokens from user to this contract
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        tokenBalances[msg.sender][token] += amount;

        emit TokenDeposited(msg.sender, token, amount);
    }

    function withdrawToken(address token, uint256 amount) external {
        require(tokenBalances[msg.sender][token] >= amount, "Insufficient token balance");

        tokenBalances[msg.sender][token] -= amount;

        bool success = IERC20(token).transfer(msg.sender, amount);
        require(success, "Token transfer failed");

        emit TokenWithdrawn(msg.sender, token, amount);
    }

    function getTokenBalance(address user, address token) external view returns (uint256) {
        return tokenBalances[user][token];
    }
}
