// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Token/ERC721.sol";
import "./Interfaces/IFlowers.sol";

contract flowers is ERC721, IFlowers{
        using Counters for Counters.Counter;
        Counters.Counter private _tokenIdCounter;

        mapping(address => mapping(uint256 => uint256)) private userOwnesPetals;       

        uint256 public fixedNFTAmount = 10;
        constructor() ERC721("Flower NFT", "Flower"){
                _setBaseURI("https://gateway.pinata.cloud/ipfs/QmWF8jQYSLnqzYh5LqBVxR1RKNbPFBw77zmA8sRdChyA9t/");
        }

        function mintFlowerNFT() public returns (uint256) {
                _tokenIdCounter.increment();
                uint256 newItemId = _tokenIdCounter.current();
                require(newItemId <= fixedNFTAmount,"Exceeds the minting Limit");

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

        function upgradePetals(address account, uint256 tokenId, uint256 _amount) external override {
                userOwnesPetals[account][tokenId] += _amount;

                emit PetalsUpgraded(
                        account,
                        tokenId,
                        _amount
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