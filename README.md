# STX NFT Marketplace

A decentralized NFT (Non-Fungible Token) marketplace built on the Stacks blockchain using Clarity smart contracts. This project enables users to mint, list, buy, and manage NFTs in a decentralized manner.

## Features

- Mint new NFTs (restricted to contract owner)
- Create listings for NFTs
- Update listing prices
- Cancel listings
- Buy NFTs
- View all listings and individual listing details
- Check NFT ownership
- Event system for tracking marketplace activities

## Smart Contract

The main smart contract `nft-marketplace.clar` implements the following functionality:

- NFT token definition
- Listing management (create, update, cancel)
- NFT purchases
- Minting new NFTs
- Utility functions for querying listings and NFT ownership

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet): A Clarity runtime packaged as a command line tool.

### Installation

1. Clone the repository:

2. Install Clarinet by following the instructions in the [Clarinet repository](https://github.com/hirosystems/clarinet).

### Usage

1. Test the contract using Clarinet:

2. Deploy the contract to the Stacks testnet or mainnet using the Stacks CLI or Clarinet.

## Contract Functions

- `create-listing`: Create a new NFT listing
- `cancel-listing`: Cancel an existing listing
- `update-listing-price`: Update the price of a listing
- `buy-nft`: Purchase an NFT from a listing
- `mint-nft`: Mint a new NFT (contract owner only)
- `get-listing`: Get details of a specific listing
- `get-all-listings`: Get all current listings
- `get-nft-owner`: Check the owner of an NFT
- `is-token-listed`: Check if a token is currently listed.
