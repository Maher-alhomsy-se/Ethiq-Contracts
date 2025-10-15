# 🏦 Custodial Wallet Smart Contract

**CustodialWallet** is a secure Ethereum smart contract designed to hold, transfer, and manage users’ **USDC** and **ETHIQ** token balances on-chain.  
It provides an efficient custodial system that allows user deposits, internal transfers, payments between users, and withdrawals — all controlled by strict access and ownership rules.

---

## ⚙️ Features

- 🔐 **Secure Custody:** Safely stores ERC-20 tokens (`USDC`, `ETHIQ`) with non-reentrant transaction protection.
- 👤 **User Identification:** Each user is mapped by a unique `userId` (`bytes32`), generated from their wallet address.
- 💸 **Deposit & Withdraw:** Users can deposit and withdraw tokens to/from their custodial balance.
- 🔄 **Internal Transfers:** The contract owner can move balances internally between users (e.g., settlement or reconciliation).
- 💰 **Payments Between Users:** Users can send token balances to other users directly within the system.
- 🛡️ **Access Control:**
  - **Owner** has authority over internal transfers.
  - **Users** can only manage their own funds (deposit, withdraw, and pay).

---

## 🧩 Contract Overview

| Function                            | Access | Description                                                       |
| ----------------------------------- | ------ | ----------------------------------------------------------------- |
| `depositEthiq(userId, amount)`      | User   | Deposit ETHIQ tokens into custody.                                |
| `depositUSDC(userId, amount)`       | User   | Deposit USDC tokens into custody.                                 |
| `withdrawEthiq(userId, to, amount)` | User   | Withdraw ETHIQ tokens to an external address.                     |
| `withdrawUsdc(userId, to, amount)`  | User   | Withdraw USDC tokens to an external address.                      |
| `payEthiq(userId, to, amount)`      | User   | Send ETHIQ balance to another registered user.                    |
| `payUsdc(userId, to, amount)`       | User   | Send USDC balance to another registered user.                     |
| `transferEthiq(from, to, amount)`   | Owner  | Internal transfer of ETHIQ between user balances.                 |
| `transferUsdc(from, to, amount)`    | Owner  | Internal transfer of USDC between user balances.                  |
| `getEthiqBalance(userId)`           | Public | View user ETHIQ balance.                                          |
| `getUsdcBalance(userId)`            | Public | View user USDC balance.                                           |
| `getUserId(address)`                | Public | Utility function to derive `bytes32` user ID from wallet address. |

---

## 📜 Events

| Event                                                       | Description                                      |
| ----------------------------------------------------------- | ------------------------------------------------ |
| `DepositEthiq(bytes32 userId, uint256 amount)`              | Emitted when a user deposits ETHIQ.              |
| `DepositUsdc(bytes32 userId, uint256 amount)`               | Emitted when a user deposits USDC.               |
| `WithdrawEthiq(bytes32 userId, address to, uint256 amount)` | Emitted when a user withdraws ETHIQ.             |
| `WithdrawUsdc(bytes32 userId, address to, uint256 amount)`  | Emitted when a user withdraws USDC.              |
| `TransferEthiq(bytes32 from, bytes32 to, uint256 amount)`   | Emitted on internal ETHIQ transfer by owner.     |
| `TransferUsdc(bytes32 from, bytes32 to, uint256 amount)`    | Emitted on internal USDC transfer by owner.      |
| `PayEthiq(bytes32 userId, address to, uint256 amount)`      | Emitted when a user sends ETHIQ to another user. |
| `PayUsdc(bytes32 userId, address to, uint256 amount)`       | Emitted when a user sends USDC to another user.  |

---

## 🔒 Security

- Uses **OpenZeppelin**’s `Ownable`, `ReentrancyGuard`, and `SafeERC20` modules for safety.
- Prevents unauthorized withdrawals and transfers.
- Guards against reentrancy attacks.
- Ensures valid token addresses during deployment.

---

## 🚀 Deployment

### Constructor

```solidity
constructor(address _usdc, address _ethiq)
```
