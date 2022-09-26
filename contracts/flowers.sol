// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Token/ERC721.sol";
import "./Interfaces/IFlowers.sol";
import "./Interfaces/IEnergyToken.sol";

contract flowers is ERC721, IFlowers, Ownable{
        using Counters for Counters.Counter;
        Counters.Counter private _tokenIdCounter;
        IEnergyToken tokenContract;

        mapping (address => mapping(uint256 => uint256)) private userOwnesPetals;      
        mapping (address => bool) private whitelistedByOwner; 

        //Hardcoded this Because I only have 10 token URIs deployed on pinata
        uint256 public constant maxNFTAmount = 10;
        
        constructor() ERC721("Flower NFT", "Flower"){
                _setBaseURI("https://gateway.pinata.cloud/ipfs/QmWF8jQYSLnqzYh5LqBVxR1RKNbPFBw77zmA8sRdChyA9t/");
        }

        modifier mintingPermission{
                require(whitelistedByOwner[msg.sender] == true 
                || msg.sender == owner(),"Not Owner or Not Whitelisted by Owner");
                _;
        }

        function mintFlowerNFT() public mintingPermission returns (uint256) {
                _tokenIdCounter.increment();
                uint256 newItemId = _tokenIdCounter.current();
                require(newItemId <= maxNFTAmount,"Exceeds the minting Limit");

                _safeMint(msg.sender, newItemId);
                
                userOwnesPetals[msg.sender][newItemId] = 1;
                uint256 petals = userOwnesPetals[msg.sender][newItemId];
                
                emit FlowerMinted(
                        msg.sender, 
                        newItemId,  
                        petals
                );
                
                return newItemId;
        }

        function whitelistUser(address user) public onlyOwner{
                whitelistedByOwner[user] = true;
        }

        function upgradeFlowers(uint256 tokenId, IEnergyToken _tokenContract, uint256 energyTokenAmount) 
                public returns(uint256 upgradedpetals){    
        tokenContract = _tokenContract;
        require(msg.sender == ownerOf(tokenId),"You're not the owner of this token Id");
        require(energyTokenAmount >= 10 ,"Minimum amount is 10");

        uint256 energyBalace = tokenContract.balanceOf(msg.sender);
        require(energyBalace >= 10,"Insufficient Energy tokens");

        uint256 remainder = energyTokenAmount%10;
        uint256 energyBurnAmount = energyTokenAmount - remainder;
        uint256 petalAmount = energyTokenAmount/10;

        upgradePetals(msg.sender, tokenId, petalAmount);

        tokenContract.burn(msg.sender, energyBurnAmount);

        upgradedpetals = balanceOfPetals(msg.sender, tokenId);
    }

        function upgradePetals(address account, uint256 tokenId, uint256 amount) private  {
                userOwnesPetals[account][tokenId] += amount;

                emit PetalsUpgraded(
                        account,
                        tokenId,
                        amount
                );
        }

        function balanceOfPetals(address to, uint256 nftId) public view override returns(uint256){
                return userOwnesPetals[to][nftId];
        }        

        function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
                uint256 petals = userOwnesPetals[from][tokenId];
                delete userOwnesPetals[from][tokenId];
                userOwnesPetals[to][tokenId] += petals;
        }
}