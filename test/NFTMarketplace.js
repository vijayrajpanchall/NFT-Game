const { expect } = require("chai");
const { ethers, hre } = require("hardhat");
require("@nomiclabs/hardhat-waffle");

describe("Flower MarketPlace", async function () {
  let marketplace;
  let nftContract;
  let marketingWallet;
  let seller;
  let buyer;
  let user;

  beforeEach(async () => {
    const [owner, Buyer, MarketingWallet, User] = await ethers.getSigners();
    contractOwner = owner.address;
    seller = owner;
    buyer = Buyer;
    marketingWallet = MarketingWallet;
    user = User;

    const Marketplace = await ethers.getContractFactory("flowerMarketplace");
    const NftContract = await ethers.getContractFactory("flowers");
    nftContract = await NftContract.deploy();

    marketplace = await Marketplace.deploy(
      nftContract.address,
      5,
      marketingWallet.address
    );
    await nftContract.mintFlowerNFT();
    await nftContract.approve(marketplace.address, 1);
    await marketplace.createMarketItem(1, 1000000000000000000n);
  });

  it("Listing price should be greater than of equal to 1 ether", async function () {
    await nftContract.mintFlowerNFT();
    await nftContract.approve(marketplace.address, 2);

    await expect(marketplace.createMarketItem(2, 1000000)).to.revertedWith(
      "Price must be cannot be zero"
    );
  });

  it("User able to list NFT on marketplace", async function () {
    expect(await nftContract.balanceOf(marketplace.address)).to.equal(1);
  });

  it("Should change Marketing fees", async function () {
    await marketplace.SetMarketingFee(10);
    const newMarketingFee = await marketplace.marketingFee();
    expect(newMarketingFee).to.equal(10);
  });

  it("Should change Marketing wallet", async function () {
    await marketplace.SetMarketingWallet(user.address);
    const newMarketingWallet = await marketplace.marketingWallet();
    expect(newMarketingWallet).to.equal(user.address);
  });
  it("User can withdraw their NFT from marketplace any time", async function () {
    await marketplace.cancelMarketItem(1);

    expect(await nftContract.balanceOf(marketplace.address)).to.equal(0);
  });

  it("Should revert if you are not seller of NFT but call withdraw nft", async function () {
    await expect(marketplace.connect(user).cancelMarketItem(1)).to.revertedWith(
      "Caller not an owner of the market item"
    );
  });

  it("Should Transfer remaining balance to the seller", async function () {
    const prevBalance = await ethers.provider.getBalance(buyer.address);
    const prevBalanceInEth = ethers.utils.formatEther(prevBalance);
    const buyerProvide = 10100000000000000000n; //10ethers
    await marketplace.connect(buyer).BuyFlowerNFT(1, { value: buyerProvide });

    const balance = await ethers.provider.getBalance(buyer.address);
    const balanceInEth = ethers.utils.formatEther(balance);

    const differenceInEtherBal = Math.floor(prevBalanceInEth - balanceInEth);

    expect(differenceInEtherBal).to.equal(1);
  });

  it("Should Transfer NFT to the buyer", async function () {
    await marketplace
      .connect(buyer)
      .BuyFlowerNFT(1, { value: 1200000000000000000n });

    expect(await nftContract.balanceOf(buyer.address)).to.equal(1);
  });

  it("Should Transfer Ethers to the seller", async function () {
    const prevBalance = await ethers.provider.getBalance(seller.address);
    const prevBalanceInEth = ethers.utils.formatEther(prevBalance);
    //passing 1.1 Ether bcoz its needed gas fee also
    await marketplace
      .connect(buyer)
      .BuyFlowerNFT(1, { value: 1100000000000000000n });

    const balance = await ethers.provider.getBalance(seller.address);
    const balanceInEth = ethers.utils.formatEther(balance);
    //when a buyer buy nft then in seller account ether balance will be added
    //so for that we stored  diff between prev balance and after purchasing
    const differenceInEtherBal = balanceInEth - prevBalanceInEth;

    expect(differenceInEtherBal).to.equal(1);
  });
});
