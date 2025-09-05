# de-susu 🏺

[![ETHAccra Hackathon](https://img.shields.io/badge/Hackathon-ETHAccra%202025-blue)](https://taikai.network/hackathons/ethaccra-2025)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Built on Base](https://img.shields.io/badge/Built_on-Base-0052FF)](https://base.org)
[![Built with Scaffold-ETH 2](https://img.shields.io/badge/Built_with-Scaffold--ETH_2-FF6B6B)](https://github.com/scaffold-eth/scaffold-eth-2)

## Overview

**de-susu** is a decentralized protocol on Base that enables secure, transparent, and self-custodial personal and group savings, directly inspired by the traditional "Susu" savings circles common in West Africa.

It replaces fraud-prone, informal systems with smart contracts, allowing users to save USDC in a Personal Vault or create Group Pools with friends and family. Every action is recorded on-chain, and users build their on-chain savings reputation linked to a human-readable ENS name.

## 🎯 Core Features (Implemented)

*   **Frictionless Web2-like Onboarding:** Sign in with Google or WhatsApp using **Base Account**. No seed phrases, no confusing wallet creation.
*   **In-App Funding:** Solve the "How do I get USDC?" problem with **Base Pay**, a direct fiat on-ramp using a debit/credit card.
*   **Personal Savings Vaults:** Deposit USDC into a personal, time-locked vault. Funds can only be withdrawn after a maturity date.
*   **Group Savings Pools (ROSCA):** Create a pool with custom rules (contribution amount, interval, members). ENS names provide easy, shareable identities for members.
*   **On-Chain Reputation:** All savings activity is transparently recorded on the **Ethereum Name Service (ENS)**. Your `name.susu.eth` profile becomes your verifiable savings history.
*   **Gasless Experience (Target State):** Designed to use **Base's Paymaster** to sponsor gas fees, so users only think about USDC, not ETH. *(Frontend integration in progress)*

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Blockchain** | [Base](https://base.org) | Low-cost L2 for transactions |
| **Smart Contracts** | Solidity, Foundry | Core protocol logic |
| **Onboarding** | [Base Account](https://docs.base.org/guides/onchainkit) | Social login & smart wallets |
| **Fiat On-Ramp** | [Base Pay](https://docs.base.org/guides/base-pay) | Buy USDC with card in-app |
| **Identity** | [ENS](https://ens.domains) | Human-readable names & reputation |
| **Frontend Framework**| [Scaffold-ETH 2](https://github.com/scaffold-eth/scaffold-eth-2) | Next.js boilerplate for fast development |
| **Frontend** | Next.js, RainbowKit, wagmi | User interface and wallet connection |             

## 🚀 Quickstart

### Prerequisites

- [Node.js](https://nodejs.org/en/) (>= v20.18.3)
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/)
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (For smart contract development)
- A wallet (MetaMask recommended for testing)

### Installation & Local Development

1.  **Clone the repository and install dependencies:**

    ```bash
    git clone <your-repo-url>
    cd de-susu
    yarn install
    ```

2.  **Run a local blockchain network (Terminal 1):**

    ```bash
    yarn chain
    ```
    This starts a local Anvil network at `http://localhost:8545`.

3.  **Deploy the contracts (Terminal 2):**

    ```bash
    yarn deploy
    ```
    This compiles and deploys the `GroupPoolFactory` and `PersonalVaultFactory` contracts to your local network. The contract addresses are automatically saved to `packages/nextjs/scaffold.config.ts`.

4.  **Start the frontend (Terminal 3):**

    ```bash
    yarn start
    ```
    Your dApp will open at `http://localhost:3000`.

5.  **Run smart contract tests:**
    To ensure everything works, run the comprehensive test suites:
    ```bash
    # Run all tests
    forge test

    # Run specific test files
    forge test --match-path test/GroupPool/GroupPool.t.sol -vvv
    forge test --match-path test/PersonalVault/PersonalVault.t.sol -vvv
    ```

### Interacting with the dApp

1.  **On your local frontend (`http://localhost:3000`), connect your wallet.**
2.  **Get test ETH:** Use the faucet on the bottom left of the page to get test ETH for your local wallet.
3.  **Get test USDC:** Our deployment scripts mint test USDC to the deployer. You can use the `Debug Contracts` page to transfer USDC to your wallet address for testing.
4.  **Create a Vault or Pool:** Use the frontend interface to create your first personal vault or group pool!

## 🌐 Deployment

### Deploying to Base Testnet (Base Sepolia)

1.  **Set up environment variables:**
    ```bash
    cd packages/foundry
    cp .env.example .env
    ```
    Edit `.env` and add your wallet's private key and a Base Sepolia RPC URL.
    ```
    PRIVATE_KEY=your_wallet_private_key_here
    RPC_URL=https://sepolia.base.org
    ```

2.  **Deploy to Base Sepolia:**
    ```bash
    forge script script/Deploy.s.sol:DeployScript --rpc-url $RUBY_RPC_URL --broadcast --verify -vvvv
    # or using the yarn script
    yarn deploy --network baseSepolia
    ```

3.  **Update the frontend configuration:**
    After deployment, update the `targetNetworks` array in `packages/nextjs/scaffold.config.ts` to include `baseSepolia` and add the new contract addresses.

### Deploying the Frontend

The frontend is a standard Next.js app. You can deploy it to Vercel, Netlify, or any other platform.

1.  **Build the project:**
    ```bash
    yarn build
    ```

2.  **Deploy to Vercel:**
    ```bash
    # Install Vercel CLI
    npm i -g vercel

    # Deploy from the nextjs directory
    cd packages/nextjs
    vercel --prod
    ```
    Ensure your environment variables (like `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`) are set in your deployment platform.

## 🧪 Testing

This project includes a comprehensive suite of Foundry tests that validate all core functionality, including ENS integration.


# Run all tests
forge test

# Run tests with detailed traces
forge test -vvv

# Run tests for a specific contract
forge test --match-contract GroupPoolTest
forge test --match-contract PersonalVaultTest

##  📄 License
This project is licensed under the MIT License. See the LICENSE file for details.