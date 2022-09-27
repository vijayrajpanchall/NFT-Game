const {expect} = require("chai");
const { ethers, hre } = require("hardhat");
require("@nomiclabs/hardhat-waffle");


describe("Flowers", async function(){
    let contractAddress;
    let contractOwner;
    let whitelistedUser;
    let nonWhitelistedAddr;
    let user;

    beforeEach(async() => {        
        const [owner, WhitelistedUser, nonWhitelisted, user1] = await ethers.getSigners();
        contractOwner = owner.address;
        whitelistedUser = WhitelistedUser;
        nonWhitelistedAddr = nonWhitelisted;
        user = user1;        

        const Flowers = await ethers.getContractFactory("flowers");

        contractAddress = await Flowers.deploy();
    })

    it("Should return 1 petal initially when NFT minted", async function () {
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
        expect(afterMinting).to.be.equal(1);
    }); 



    it("Whitelisted user can mint NFT", async function () {    
        await contractAddress.whitelistUser(whitelistedUser.address);
        let functionCalled;
        if (await contractAddress.connect(whitelistedUser).mintFlowerNFT()){
            functionCalled = 1;
        }       
        expect(functionCalled).to.be.equal(1);
    });   

    it("Non - Whitelisted user can not mint NFT", async function () {
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

        for (let index = 0; index < tokenMinted; index++) {
            await contractAddress.mintFlowerNFT();
        }
        const tokenURI = await contractAddress.tokenURI(tokenMinted);
        const baseURI = await contractAddress.baseURI();
        expect(tokenURI).to.equal(baseURI +"3.json");
    });

    it("Petals will transfer when user transfer NFT", async function () {
        await contractAddress.mintFlowerNFT();

        await contractAddress.transferFrom(contractOwner, user.address, 1);

        expect(await contractAddress.connect(user).balanceOfPetals(user.address, 1)).to.equal(1);
    });

    it("Should revert if user wants upgrade petals but provide less energy tokens", async function () {
        await contractAddress.mintFlowerNFT();
        const EnergyToken = await ethers.getContractFactory("energyToken");
        const energyToken = await EnergyToken.deploy();
        await energyToken.mint(contractOwner, 100);

        await expect(contractAddress.upgradeFlowers(1, energyToken.address, 9))
            .to.revertedWith("Providing less energy tokens");
    });

    it("Should revert if user don't have sufficient energy token in account", async function () {
        await contractAddress.mintFlowerNFT();
        const EnergyToken = await ethers.getContractFactory("energyToken");
        const energyToken = await EnergyToken.deploy();
        await energyToken.mint(contractOwner, 9);

        await expect(contractAddress.upgradeFlowers(1, energyToken.address, 10))
            .to.revertedWith("Insufficient Energy tokens");
    });

    it("Should burn energy token after upgrade petals", async function () {
        await contractAddress.mintFlowerNFT();
        const EnergyToken = await ethers.getContractFactory("energyToken");
        const energyToken = await EnergyToken.deploy();
        await energyToken.mint(contractOwner, 100);

        await contractAddress.upgradeFlowers(1, energyToken.address, 100)
   
        expect(await energyToken.balanceOf(contractOwner)).to.equal(0);
    });

    it("Should increase petals after providing sufficient energy tokens", async function () {
        await contractAddress.mintFlowerNFT();
        const EnergyToken = await ethers.getContractFactory("energyToken");
        const energyToken = await EnergyToken.deploy();
        await energyToken.mint(contractOwner, 100);

        await contractAddress.upgradeFlowers(1, energyToken.address, 100)
        //1petal price is 10
        //for 100tokens = 10 petals
        const petalsAfterUpgrade = 1 + 10; 
        expect(await contractAddress.balanceOfPetals(contractOwner, 1))
        .to.equal(petalsAfterUpgrade);
    });
    it("Should only burn those energy tokens which are using for upgrade", async function () {
        await contractAddress.mintFlowerNFT();
        const EnergyToken = await ethers.getContractFactory("energyToken");
        const energyToken = await EnergyToken.deploy();
        await energyToken.mint(contractOwner, 100);

        await contractAddress.upgradeFlowers(1, energyToken.address, 95)
        //here  user passing 95 tokens but it will burn only  90 tokens
        //because we only needed 10 token per petal for upgrade.
        expect(await energyToken.balanceOf(contractOwner)).to.equal(10);
    });

    it("Should revert if user is not owner of NFT and calls upgrade using energy tokens", async function () {
        await contractAddress.mintFlowerNFT();
        const EnergyToken = await ethers.getContractFactory("energyToken");
        const energyToken = await EnergyToken.deploy();
        await energyToken.mint(user.address, 100);

        await expect(contractAddress.connect(user).upgradeFlowers(1, energyToken.address, 10))
            .to.revertedWith("You're not the owner of this token Id");
    });

    it("Owner can change per petal energy token required", async function () {
        const defaultValue = await contractAddress.perPetalEnergyRequired();
        await contractAddress.changePerPetalEnergyRequired(100);

        expect(await contractAddress.perPetalEnergyRequired()).to.not.eql(defaultValue);
    });
})



