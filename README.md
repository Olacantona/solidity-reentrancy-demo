# Reentrancy Lab (Foundry)

This project demonstrates a **classic reentrancy vulnerability** in Solidity and how to prevent it using OpenZeppelin’s `ReentrancyGuard`.

## 📂 Contracts
- **Bank.sol** – A vulnerable ETH bank that allows deposits and withdrawals. It is vulnerable to reentrancy because it updates balances *after* sending ETH.
- **Attacker.sol** – A malicious contract that exploits `Bank` by recursively calling `withdraw()` to drain funds.
- **SafeBank.sol** – A fixed version of `Bank` that uses `ReentrancyGuard` and the **checks-effects-interactions** pattern.

## 🧪 Tests
- **testExploitBank()** – Demonstrates the attacker successfully draining the vulnerable `Bank`.
- **testAttackFailsOnSafeBank()** – Shows how the same attack fails against `SafeBank`.

## ⚡️ Running Locally

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed (`forge --version` to confirm).
- Git + a GitHub account (for version control).

### Install dependencies
```bash
forge install openzeppelin/openzeppelin-contracts --no-commit


