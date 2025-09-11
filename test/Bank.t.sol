// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "../src/Attacker.sol";

contract BankTest is Test {
    Bank bank;
    Attacker attacker;
    address user = address(0x1);

    // These must be at contract level, not inside setUp()
    receive() external payable {}
    fallback() external payable {}

    function setUp() public {
        // Deploy the Bank contract
        bank = new Bank();

        // Give user 10 ETH and deposit into the bank
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        bank.addBalance{value: 10 ether}();
        vm.stopPrank();

        // Deploy attacker contract
        attacker = new Attacker(address(bank));
    }

    function testExploit() public {
        // Fund attacker with 1 ETH
        vm.deal(address(attacker), 1 ether);

        // Execute the attack
        attacker.attack{value: 1 ether}();

        // Collect stolen funds
        attacker.collect();
    }
}
