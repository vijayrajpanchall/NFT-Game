// const {expect} = require("chai");
// const { ethers } = require("hardhat");

//     let contractAddress;
//     let contractOwner;
//     let nonWhitelistedAddr;
// const getData = async () => {
//     const [owner, nonWhitelisted] = await ethers.getSigners();
//     // console.log(owner.address);
//     // console.log(nonWhitelisted.address);
    
//     const Flowers = await ethers.getContractFactory("flowers");

//     contractAddress = await Flowers.deploy();
//     console.log(contractAddress.address)

//     //  const tokenFromOtherWallet = contractAddress.connect(nonWhitelisted);

//     await tokenFromOtherWallet.mintFlowerNFT();

// }
// getData();


// import { MockProvider } from 'ethereum-waffle';

// // const provider = new MockProvider();
// // const [wallet, otherWallet] = provider.getWallets();

// // or use a shorthand

// const [wallet, otherWallet] = new MockProvider().getWallets();

// console.log(wallet)
// console.log(otherWallet)

