const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
require("@nomiclabs/hardhat-waffle");

describe("Staking Flowers", async function () {
    let stakingContract;
    let nftContract;
    let tokenContract;
    let staker;
    let user1;

    beforeEach(async () => {
        const [owner, Staker, User1] = await ethers.getSigners();
        contractOwner = owner.address;
        staker = Staker;
        user1 = User1;

        const StakingContract = await ethers.getContractFactory("nftStaking");
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

    it("User can stake multiple NFTs", async function () {
        let nftCount = 3;
        for (let index = 0; index < nftCount; index++) {
            await nftContract.mintFlowerNFT();
        }

        await nftContract.setApprovalForAll(stakingContract.address, true);

        await stakingContract.stake([1, 2, 3]);

        expect(await nftContract.balanceOf(stakingContract.address)).to.equal(3);
    })

    it("Can not stake if not approved", async function () {
        await nftContract.mintFlowerNFT();

        await expect(
            stakingContract
                .stake([1]))
            .to.be.revertedWith
            ('ERC721: transfer caller is not owner nor approved');
    })

    it("Should transfer to Staking Contract", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.setApprovalForAll(stakingContract.address, true);

        await stakingContract.stake([1]);

        expect(await nftContract.balanceOf(stakingContract.address)).to.equal(1);
    })

    it("Should be owner if wants to stake", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.setApprovalForAll(stakingContract.address, true);

        await expect(stakingContract.connect(user1).stake([1]))
            .to.be.revertedWith("Can't stake tokens you don't own!");
    })

    it("Should revert if user not staked but call withdraw", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.setApprovalForAll(stakingContract.address, true);

        await expect(stakingContract.withdraw([1]))
            .to.be.revertedWith('You have no tokens staked');
    })

    it("User able to un-stake NFT", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.setApprovalForAll(stakingContract.address, true);
        await stakingContract.stake([1]);
        await stakingContract.withdraw([1]);

        expect(await nftContract.balanceOf(stakingContract.address)).to.equal(0);
    })

    it("User can un-stake multiple NFTs", async function () {
        let nftCount = 3;
        for (let index = 0; index < nftCount; index++) {
            await nftContract.mintFlowerNFT();
        }

        await nftContract.setApprovalForAll(stakingContract.address, true);

        await stakingContract.stake([1, 2, 3]);
        await stakingContract.withdraw([1, 2, 3]);

        expect(await nftContract.balanceOf(stakingContract.address)).to.equal(0);
    })

    it("Should owner can change reward rate per hour", async function () {
        await stakingContract.setRewardsPerHour(2000);
        expect(await stakingContract.rewardsPerHour()).to.equal(2000);
    })

    it("Should Transfer Energy token If user claim tokens", async function () {
        await nftContract.mintFlowerNFT();
        await nftContract.approve(stakingContract.address, 1);

        await stakingContract.stake([1]);
        await new Promise((resolve, reject) => {
            setTimeout(async () => {
                let data = await stakingContract.withdraw([1]);
                resolve(data);
            }, 10000)
        })

        await stakingContract.claimRewards();

        expect(await tokenContract.balanceOf(contractOwner)).to.be.above(0);

    })
})