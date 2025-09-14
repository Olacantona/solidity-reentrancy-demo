// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "../src/SafeBank.sol";
import "../src/Attacker.sol";

contract BankTest is Test {
    Bank bank;
    SafeBank safeBank;
    Attacker attacker;
    address user = address(0x1);

    function setUp() public {
        // Deploy contracts
        bank = new Bank();
        safeBank = new SafeBank();

        // Fund the bank and safebank with 10 ETH
        vm.deal(address(bank), 10 ether);
        vm.deal(address(safeBank), 10 ether);

        // Fund the test user with 5 ETH
        vm.deal(user, 5 ether);
    }

    function testExploitBank() public {
        // Deploy attacker (no value here!)
        attacker = new Attacker(address(bank));

        // Run the attack with 1 ETH
        attacker.attack{value: 1 ether}();

        emit log_named_uint("Bank balance after attack", address(bank).balance);
        emit log_named_uint("Attacker balance after attack", address(attacker).balance);
    }

    function testAttackFailsOnSafeBank() public {
        // Deploy attacker (no value here!)
        attacker = new Attacker(address(safeBank));

        // Try to attack
        vm.expectRevert();
        attacker.attack{value: 1 ether}();

        emit log_named_uint("SafeBank balance after attempted attack", address(safeBank).balance);
        emit log_named_uint("Attacker balance after attempted attack", address(attacker).balance);

        // SafeBank should still hold funds
        assertEq(address(safeBank).balance, 10 ether);
    }
}
