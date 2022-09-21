// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract flowerMarketplace is ERC721Holder, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    IERC721 public nftContract;

    address payable owner;

    uint256 public marketingFee;
    address payable marketingWallet;

    constructor(address _nftContract, uint256 _fee,address _marketingWallet) {
        owner = payable(msg.sender);
        nftContract = IERC721(_nftContract);
        marketingFee = _fee;
        marketingWallet = payable(_marketingWallet);
    }

    struct MarketItem {
        address nftAddress;
        uint256 itemId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 marketingFee;
        uint256 feeAmount;
        uint256 totalPrice;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        address nftAddress,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 marketingFee,
        uint256 feeAmount,
        uint256 totalPrice,
        bool sold
    );

    function SetMarketingFee(uint256 _fee) public  {
        require(msg.sender == owner, "Only owner can update marketingFee");
        marketingFee = _fee;
    } 

    function SetMarketingWallet(address _marketingWallet) public  {
        require(msg.sender == owner, "Only owner can update wallet");
        marketingWallet = payable(_marketingWallet);
    } 

    
    /* Places an item for sale on the marketplace */
    function createMarketItem(uint256 tokenId, uint256 priceInEther) public nonReentrant {
        require(priceInEther >= 1 ether, "Price must be cannot be zero");         
            

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        uint256 calFee = (priceInEther * marketingFee) / 100;
        uint256 totalPrice = priceInEther + calFee;

        idToMarketItem[itemId] = MarketItem(
            address(nftContract),
            itemId,
            tokenId,
            msg.sender,
            address(0),
            priceInEther,
            marketingFee,
            calFee,
            totalPrice,
            false
        );

        nftContract.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit MarketItemCreated(
            address(nftContract),
            itemId,
            tokenId,
            msg.sender,
            address(0),
            priceInEther,
            marketingFee,
            calFee,
            totalPrice,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function BuyFlowerNFT(uint256 itemId) public payable nonReentrant {
        uint256 totalPrice = idToMarketItem[itemId].totalPrice;
            
        require(msg.value >= totalPrice, "Token Balance is low");
        
        nftContract = IERC721(idToMarketItem[itemId].nftAddress);

        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;        
        uint256 feeAmount = idToMarketItem[itemId].feeAmount; 

        if (feeAmount > 0) {
            payable(marketingWallet).transfer(feeAmount);  
        }

        uint256 actualPrice = totalPrice - feeAmount;     

        payable(seller).transfer(actualPrice);

        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
    }

    /* Calnce the sale of a marketplace item */
    /* Transfers ownership of the item */
    function cancleMarketItem(uint256 itemId) public nonReentrant {
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            idToMarketItem[itemId].seller == msg.sender,
            "Caller not an owner of the market item"
        );

        nftContract = IERC721(idToMarketItem[itemId].nftAddress);        
        
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
    } 
}