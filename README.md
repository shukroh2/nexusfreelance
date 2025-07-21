# NexusFreelance Smart Contract

## Overview

NexusFreelance is a decentralized freelance platform powered by smart contracts. This repository contains the core contract code, configuration files, and supporting scripts for deploying and interacting with the NexusFreelance protocol.

## Features

- **Secure Escrow:** Funds are held in escrow until work is completed and approved.
- **Automated Payments:** Payments are released automatically upon job completion.
- **Dispute Resolution:** Built-in mechanisms for handling disputes between clients and freelancers.
- **Network Support:** Configurable for Mainnet and Testnet environments.

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) and npm
- [Hardhat](https://hardhat.org/) or [Truffle](https://www.trufflesuite.com/)
- A supported wallet (e.g., MetaMask)
- Access to Ethereum Mainnet or Testnet

### Installation

Clone the repository:

```
git clone https://github.com/yourusername/nexusfreelance.git
cd nexusfreelance
npm install
```

### Configuration

Edit the settings files in the `settings/` directory to configure network parameters:

- `settings/Mainnet.toml`
- `settings/Testnet.toml`

### Deployment

Deploy the contract using Hardhat:

```
npx hardhat run scripts/deploy.js --network mainnet
```

Or for testnet:

```
npx hardhat run scripts/deploy.js --network testnet
```

### Usage

Interact with the contract using the provided scripts or integrate with your frontend application. See the `scripts/` directory for examples.

## File Structure

- `contracts/` — Smart contract source code
- `scripts/` — Deployment and interaction scripts
- `settings/` — Network configuration files
- `.gitignore` — Files and directories excluded from version control

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.
