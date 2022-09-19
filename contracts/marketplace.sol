// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./Interfaces/IERC2981.sol";
import "./Interfaces/IWETH.sol";
import "./Token/ERC721.sol";

contract NFTBuySell is IERC721Receiver, ReentrancyGuard {
    using Strings for string;
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    // IERC1155 public nftContract;
    IERC20 public tokenContract;
    // LoudNft public loudNft;
    ERC721 public nftContract;

    address payable owner;

    uint256 public marketingFee;
    address payable marketingWallet;

    // uint256 listingPrice = 1 ether;

    constructor(address _nftContract, address _tokenContract,uint256 _fee,address _marketingWallet) {
        owner = payable(msg.sender);
        tokenContract = IERC20(_tokenContract);
        nftContract = ERC721(_nftContract);
        marketingFee = _fee;
        marketingWallet = payable(_marketingWallet);
    }

    struct MarketItem {
        address nftAddress;
        address tokenAddress;
        string tokenName;
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
        address tokenAddress,
        string tokenName,
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

    event LogErrorString(string message);
    event LogErrorBytes(bytes data);

    function SetMarketingFee(uint256 _fee) public  {
        require(msg.sender == owner, "Only owner can update marketingFee");
        marketingFee = _fee;
    } 

    function SetMarketingWallet(address _marketingWallet) public  {
        require(msg.sender == owner, "Only owner can update wallet");
        marketingWallet = payable(_marketingWallet);
    } 

    
    /* Places an item for sale on the marketplace */
    function createMarketItem(uint256 tokenId, uint256 price, address _nftContract, address _tokenAddress,string memory _tokenName) public nonReentrant {
        require(price > 0, "Price must be cannot be zero");         
        nftContract = ERC721(_nftContract);
        

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        uint256 calFee = (price * marketingFee) / 100;
        uint256 totalPrice = price + calFee;

        idToMarketItem[itemId] = MarketItem(
            _nftContract,
            _tokenAddress,
            _tokenName,
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
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
            _nftContract,
            _tokenAddress,
            _tokenName,
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
            marketingFee,
            calFee,
            totalPrice,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 itemId) public payable nonReentrant {
        uint256 totalPrice = idToMarketItem[itemId].totalPrice;
        uint256 price = idToMarketItem[itemId].price; 
        string memory tokenName = idToMarketItem[itemId].tokenName; 

        if(tokenName.upper().compareTo("BNB")) {            
            require(msg.value >= totalPrice, "Token Balance is low");
        }  
        else {
            require(tokenContract.balanceOf(msg.sender) >= totalPrice, "Token Balance is low");
            
            tokenContract = IERC20(idToMarketItem[itemId].tokenAddress);
        }
        
        nftContract = ERC721(idToMarketItem[itemId].nftAddress);

        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;        
        uint256 royaltyFeeAmount = 0;
        uint256 feeAmount = idToMarketItem[itemId].feeAmount; 

        if(tokenName.upper().compareTo("BNB")) {            
                      
            try nftContract.royaltyFee(tokenId) returns (uint256 royaltyFee) {
                royaltyFeeAmount = (price / 100) * royaltyFee;
                if (royaltyFeeAmount > 0) {
                    address creator = nftContract.getCreator(tokenId);
                    payable(creator).transfer(royaltyFeeAmount);
                }
            }
            catch Error(string memory reason) {
                emit LogErrorString(reason);
            } 
            catch (bytes memory reason) {
                // catch failing assert()
                emit LogErrorBytes(reason);
            }

            if (feeAmount > 0) {
                payable(marketingWallet).transfer(feeAmount);  
            }

            uint256 actualPrice = totalPrice - royaltyFeeAmount - feeAmount;

            payable(seller).transfer(actualPrice);
        }  
        else {
            try nftContract.royaltyFee(tokenId) returns (uint256 royaltyFee) {
                royaltyFeeAmount = (price / 100) * royaltyFee;
                if (royaltyFeeAmount > 0) {
                    giveRoyalty(msg.sender, tokenId, royaltyFeeAmount);
                }
            }
            catch Error(string memory reason) {
                emit LogErrorString(reason);
            } 
            catch (bytes memory reason) {
                // catch failing assert()
                emit LogErrorBytes(reason);
            }

            if (feeAmount > 0) {
                tokenContract.transferFrom(msg.sender, marketingWallet, feeAmount);  
            }

            uint256 actualPrice = totalPrice - royaltyFeeAmount - feeAmount;

            tokenContract.transferFrom(msg.sender, seller, actualPrice);
        }   

        

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

        nftContract = ERC721(idToMarketItem[itemId].nftAddress);        
        
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns onlyl items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

     /* Returns items that a user Have*/
    function fetchUserNFTs(address userAddress) public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == userAddress) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == userAddress) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function giveRoyalty(address _buyer, uint256 _id, uint256 _amount) internal returns (bool) {
        address creator = nftContract.getCreator(_id);
        tokenContract.transferFrom(_buyer, creator, _amount);
        return true;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }    
}