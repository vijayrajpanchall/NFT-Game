// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // We get the contract to deploy

  const [deployer] = await ethers.getSigners();
  console.log("Deployer: ", await deployer.address);
  

  // for Flowers contract
  const Flowers = await ethers.getContractFactory("flowers");
  const flowers = await Flowers.deploy();
  const flowerTokenAddress = flowers.address;  
  console.log("Flowers deployed to:", flowerTokenAddress);

  //For energy Token
  const EnergyToken = await ethers.getContractFactory("energyToken");
  const energyToken = await EnergyToken.deploy();
  const energyTokenAddress = energyToken.address;

  console.log("EnergyToken deployed to:", energyTokenAddress);

  //For Marketplace
  const Marketplace = await ethers.getContractFactory("flowerMarketplace");
  const marketplace = await Marketplace.deploy(flowerTokenAddress, 5, deployer.address);

  console.log("Marketplace deployed to:", marketplace.address);

  //for nft Staking
  const NFTStaking = await ethers.getContractFactory("stakeFlowers");
  const nftStaking = await NFTStaking.deploy(flowerTokenAddress, energyTokenAddress);

  console.log("NFTStaking deployed to:", nftStaking.address);

  //for upgrading flowers
  const UpgradeFlowers = await ethers.getContractFactory("upgrade");
  const upgradeFlowers = await UpgradeFlowers.deploy(flowerTokenAddress, energyTokenAddress);

  console.log("UpgradeFlowers deployed to:", upgradeFlowers.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

