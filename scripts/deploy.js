const hre = require("hardhat");

async function main() {
  // We get the contract to deploy

  const [deployer] = await ethers.getSigners();
  console.log("Deployer: ", await deployer.address);
  

  // for Flowers contract
  const Flowers = await ethers.getContractFactory("flowers");
  const flowers = await Flowers.deploy();
  const flowerTokenAddress = await flowers.address;  
  console.log("Flowers contract deployed to:", flowerTokenAddress);

  

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
  const NFTStaking = await ethers.getContractFactory("nftStaking");
  const nftStaking = await NFTStaking.deploy(flowerTokenAddress, energyTokenAddress);

  console.log("NFT Staking deployed to:", nftStaking.address);

  const NNFTStaking = await ethers.getContractFactory("bicoNFTStaking");
  const nnftStaking = await NNFTStaking.deploy(flowerTokenAddress, energyTokenAddress);

  console.log("NFT Staking deployed to:", nnftStaking.address);

}

async function verify(flowerTokenAddress, args) {
  console.log("verifying contract ...")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified")      
    } else{
      console.log(e)
    }
    
  }  
}

// await run("verify:verify", {
//   address: contractAddress,
//   constructorArguments: args,
// })

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

