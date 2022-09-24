const {expect} = require("chai");
const { ethers, hre } = require("hardhat");
require("@nomiclabs/hardhat-waffle");


describe("Flowers", async function(){
    let contractAddress;
    let contractOwner;
    let whitelistedAddr;
    let nonWhitelistedAddr;
    let addr1;

    beforeEach(async() => {        
        const [owner, whitelistedUser, nonWhitelisted, user1] = await ethers.getSigners();
        contractOwner = owner.address;
        whitelistedAddr = whitelistedUser;
        nonWhitelistedAddr = nonWhitelisted;
        addr1 = user1;
        

        const Flowers = await ethers.getContractFactory("flowers");

        contractAddress = await Flowers.deploy();
    })

    it("Initially Every NFT token Id contains 1 petal:", async function () {
        await contractAddress.mintFlowerNFT();

        expect(await contractAddress.balanceOfPetals(contractOwner, 1)).to.equal(1);
    });

    it("Total Supply of NFT should be fixed", async function () {
        const maxNFTAmount = await contractAddress.maxNFTAmount();

        for (let index = 0; index < maxNFTAmount; index++) {
            await contractAddress.mintFlowerNFT();
        }

        await expect(contractAddress.mintFlowerNFT()).to.be.reverted;
    });

    it("Owner can mint NFT", async function () {
        const beforeMinting = await contractAddress.balanceOf(contractOwner);
        await contractAddress.mintFlowerNFT();

        const afterMinting = await contractAddress.balanceOf(contractOwner);
        expect(afterMinting).to.be.equal(beforeMinting + 1);
    }); 



    it("Whitelisted user can mint NFT", async function () {    
        await contractAddress.whitelistUser(whitelistedAddr.address);
        let functionCalled;
        if (await contractAddress.connect(whitelistedAddr).mintFlowerNFT()){
            functionCalled = 1;
        }       
        expect(functionCalled).to.be.equal(1);
    });   

    it("Non - Whitelisted user cann't mint NFT", async function () {
        await expect( contractAddress
            .connect(nonWhitelistedAddr)
            .mintFlowerNFT())
            .to.be.revertedWith('Not Owner or Not Whitelisted by Owner');
    }); 

    it("Every NFT has an attached URI", async function () {
        await contractAddress.mintFlowerNFT();

        const tokenURI = await contractAddress.tokenURI(1);
        const baseURI = await contractAddress.baseURI();

        expect(tokenURI).to.equal(baseURI + "1.json");
    });

    it("Token URI should change according to minting", async function () {
        let tokenMinted = 3;
        // let lastToken;
        for (let index = 0; index < tokenMinted; index++) {
            await contractAddress.mintFlowerNFT();
            // lastToken += 1;
        }
        const tokenURI = await contractAddress.tokenURI(tokenMinted);
        const baseURI = await contractAddress.baseURI();
        // let a = lastToken.toString();
        expect(tokenURI).to.equal(baseURI +"3.json");
    });

    it("Petals will transfer when user transfer NFT", async function () {
        await contractAddress.mintFlowerNFT();

        await contractAddress.transferFrom(contractOwner, addr1.address, 1);

        expect(await contractAddress.connect(addr1).balanceOfPetals(addr1.address, 1)).to.equal(1);
    });
})

describe("Flower MarketPlace", async function () {
    let marketplace;
    let nftContract;
    let marketingWallet;
    let seller;
    let buyer;

    beforeEach(async () => {
        const [owner, Seller, Buyer, MarketingWallet] = await ethers.getSigners();
        contractOwner = owner.address;
        seller = Seller;
        buyer = Buyer;
        marketingWallet = MarketingWallet;

        const Marketplace = await ethers.getContractFactory("flowerMarketplace");
        const NftContract = await ethers.getContractFactory("flowers");

        marketplace = await Marketplace.deploy(
            NftContract.address,
            5,
            marketingWallet.address
        );

        nftContract = await NftContract.deploy();

    })

    it("User able to list NFT on marketplace", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.approve(marketplace.address, 1);
        await marketplace.createMarketItem(1, 1000000000000000000n);

        expect(await nftContract.balanceOf(marketplace.address)).to.equal(1);

    })
})

describe.only("Staking Flowers", async function () {
    let stakingContract;
    let nftContract;
    let tokenContract;
    let staker;

    beforeEach(async () => {
        const [owner, Staker] = await ethers.getSigners();
        contractOwner = owner.address;
        staker = Staker;

        const StakingContract = await ethers.getContractFactory("stakeFlowers");
        const NftContract = await ethers.getContractFactory("flowers");
        const TokenContract = await ethers.getContractFactory("energyToken");

        nftContract = await NftContract.deploy();

        tokenContract = await TokenContract.deploy();

        stakingContract = await StakingContract.deploy(nftContract.address, tokenContract.address);

    })

    it("User able to stake NFT", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.setApprovalForAll(stakingContract.address, true);

        await stakingContract.stake([1]);

        expect(await nftContract.balanceOf(stakingContract.address)).to.equal(1);
    })

    it("Should transfer to Staking Contract", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.setApprovalForAll(stakingContract.address, true);

        await stakingContract.stake([1]);

        expect(await nftContract.balanceOf(stakingContract.address)).to.equal(1);
    })

    it("Can not stake if not approved", async function () {
        await nftContract.mintFlowerNFT();
  
        await expect(
            stakingContract
            .stake([1]))
            .to.be.revertedWith
            ('ERC721: approve caller is not owner nor approved for all');
    })
})