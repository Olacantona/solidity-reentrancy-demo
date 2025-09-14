// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SafeBank is ReentrancyGuard {
    mapping(address => uint256) public balances;

    // Deposit ETH into the bank
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
    }

    // Secure withdraw with CEI + reentrancy guard
    function withdraw() public nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient funds");

        // Effects before interactions
        balances[msg.sender] = 0;

        // Interaction after state change
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
