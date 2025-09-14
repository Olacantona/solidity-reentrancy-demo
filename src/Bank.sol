// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    mapping(address => uint256) public balances;

    // Deposit ETH into the bank
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
    }

    // Vulnerable withdraw (no reentrancy guard!)
    function withdraw() public {
        require(balances[msg.sender] != 0, "Insufficient funds");

        // Send ETH first
        (bool success,) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "ETH transfer failed");

        // Update balance after transfer (vulnerability!)
        balances[msg.sender] = 0;
    }

    // Helper: check contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
