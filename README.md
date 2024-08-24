Overview

This repository contains the source code for an NFT Marketplace Contract developed in Clarity, a smart contract language for the Stacks blockchain. The contract enables users to mint, list, buy, and manage NFTs (Non-Fungible Tokens) within the marketplace. The following functionalities are supported:

Minting NFTs: Only the contract owner can mint new NFTs.

Creating Listings: Token owners can create listings to sell their NFTs.

Updating Listings: Sellers can update the price of their active listings.

Cancelling Listings: Sellers can cancel their listings, removing them from the marketplace.

Buying NFTs: Users can purchase listed NFTs, transferring ownership and funds accordingly.

Contract Functions
Constants
contract-owner: The principal that deployed the contract, identified by tx-sender.
err-owner-only: Error code u100 for actions restricted to the contract owner.
err-not-token-owner: Error code u101 for actions restricted to the NFT owner.
err-listing-not-found: Error code u102 when a listing does not exist.
err-price-zero: Error code u103 for invalid (zero) pricing.
err-invalid-token-id: Error code u104 for invalid token IDs.
err-invalid-principal: Error code u105 for invalid principals.
err-invalid-recipient: Error code u106 for invalid recipients.

Data Variables
next-listing-id: Tracks the ID of the next listing to be created.
next-token-id: Tracks the ID of the next NFT to be minted.

NFT Management
mint-nft(recipient): Allows the contract owner to mint a new NFT and assign it to a recipient.
get-nft-owner(token-id): Fetches the owner of a specific NFT.

Listing Management
create-listing(token-id, price): Creates a new listing for a specified NFT with a sale price.
cancel-listing(listing-id): Cancels an active listing, removing it from the marketplace.
update-listing-price(listing-id, new-price): Updates the price of an existing listing.
buy-nft(listing-id): Allows a user to purchase an NFT from an active listing.

Read-Only Functions
get-next-listing-id(): Retrieves the next available listing ID.
get-next-token-id(): Retrieves the next available token ID.
get-listing(listing-id): Fetches the details of a specific listing.
get-total-listings(): Returns the total number of listings created.

Error Handling
The contract uses a set of predefined error codes to handle various scenarios such as unauthorized access, invalid token operations, and incorrect pricing. These are crucial for ensuring the contract operates securely and predictably.

How to Use
Deploy the Contract: The contract owner deploys the contract on the Stacks blockchain.

Minting NFTs: The contract owner mints NFTs and assigns them to specified recipients.

Creating Listings: NFT owners can create listings for their tokens, setting a sale price.

Buying NFTs: Users can purchase NFTs by sending the required amount of STX to the seller.

Managing Listings: Sellers can update or cancel their listings as needed.
