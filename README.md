# Flower NFT Game(NFT Staking, NFT Marketplace)

## Table of Content

- [Project Description](#project-description)
- [Technologies Used](#technologies-used)
- [Folder Structure](#a-typical-top-level-directory-layout)
- [Install and Run](#install-and-run)

## Project Description

Flower NFT Game is a NFT staking and NFT marketplace game. This game is built on the Ethereum blockchain. In this game, users can mint NFT and stake it to earn energy tokens. Users can use these energy tokens to upgrade their NFT petals. Users can also sell their NFTs in the marketplace. This game is built using the following technologies:


## Technologies Used

- [Solidity](https://docs.soliditylang.org/en/v0.8.7/)
- [OpenZeppelin](https://docs.openzeppelin.com/contracts/4.x/)
- [Hardhat](https://hardhat.org/)
- [Ethers.js](https://docs.ethers.io/v5/)

## A typical top-level directory layout

    .
    ├── contracts/                # Solidity smart contracts
    ├── scripts/                  # Scripts to deploy smart contracts
    ├── test/                     # Test scripts for smart contracts
    ├── .env                      # Environment variables
    ├── .gitignore                # Git ignore file
    ├── hardhat.config.js         # Hardhat configuration file
    ├── package.json              # Package manager file
    └── README.md                 # Readme file

## Install and Run

1. Clone the repository

```bash
git clone
```

2. Install dependencies

```bash
npm install
```

3. Create a .env file in the root directory and add the following environment variables

```bash
MNEMONIC="your mnemonic"
INFURA_API_KEY="your infura api key"
ETHERSCAN_API_KEY="your etherscan api key"
```

4. Compile the smart contracts

```bash
npx hardhat compile
```

5. Run the tests

```bash
npx hardhat test
```

6. Deploy the smart contracts

```bash
npx hardhat run scripts/deploy.js --network rinkeby
```

## Test
For a unit testing smart contract using the command line.
```bash
npx hardhat test
```
Expecting Test result.

```bash
  Flowers
    ✔ Should return 1 petal initially when NFT minted (148ms)
    ✔ Total Supply of NFT should be fixed (986ms)
    ✔ Owner can mint NFT (91ms)
    ✔ Whitelisted user can mint NFT (100ms)
    ✔ Non - Whitelisted user can not mint NFT
    ✔ Every NFT has an attached URI (110ms)
    ✔ Token URI should change according to minting (225ms)
    ✔ Petals will transfer when user transfer NFT (124ms)
    ✔ Should revert if user wants upgrade petals but provide less energy tokens (247ms)
    ✔ Should revert if user dont have sufficient energy token in account (223ms)
    ✔ Should burn energy token after upgrade petals (231ms)
    ✔ Should increase petals after providing sufficient energy tokens (291ms)
    ✔ Should only burn those energy tokens which are using for upgrade (269ms)
    ✔ Should revert if user is not owner of NFT and calls upgrade using energy tokens (251ms)
    ✔ Owner can change per petal energy token required (46ms)

  Flower MarketPlace
    ✔ Listing price should be greater than of equal to 1 ether (99ms)
    ✔ User able to list NFT on marketplace
    ✔ Should change Marketing fees
    ✔ Should change Marketing wallet (48ms)
    ✔ User can withdraw their NFT from marketplace any time (92ms)
    ✔ Should revert if you are not seller of NFT but call withdraw nft (42ms)
    ✔ Should Transfer remaining balance to the seller (86ms)
    ✔ Should Transfer NFT to the buyer (87ms)
    ✔ Should Transfer Ethers to the seller (69ms)

  Staking Flowers
    ✔ User able to stake NFT (154ms)
    ✔ User can stake multiple NFTs (312ms)
    ✔ Can not stake if not approved (75ms)
    ✔ Should transfer to Staking Contract (142ms)
    ✔ Should be owner if wants to stake (105ms)
    ✔ Should revert if user not staked but call withdraw (103ms)
    ✔ User able to un-stake NFT (237ms)
    ✔ User can un-stake multiple NFTs (498ms)
    ✔ Should owner can change reward rate per hour
    ✔ Should Transfer Energy token If user claim tokens (10308ms)


  34 passing (38s)
```

After testing if you want to deploy the contract using the command line.

```bash

$ npx hardhat node
# Open another Terminal
$ npx hardhat run scripts/deploy.js

# result in npx hardhat node Terminal
web3_clientVersion
eth_chainId
eth_accounts
eth_chainId
eth_estimateGas
eth_gasPrice
eth_sendTransaction
  Contract deployment: <UnrecognizedContract>
  Contract address:    0x5fb...aa3
  Transaction:         0x4d8...945
  From:                0xf39...266
  Value:               0 ETH
  Gas used:            323170 of 323170
  Block #1:            0xee6...85d

eth_chainId
eth_getTransactionByHash
eth_blockNumber
eth_chainId (2)
eth_getTransactionReceipt

```

