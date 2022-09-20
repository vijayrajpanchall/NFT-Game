// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Token/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract flowers is ERC721{
        using Counters for Counters.Counter;
        // using Integers for uint256;
        Counters.Counter private _tokenIdCounter;

        // mapping(uint256 => uint256) private tokenIdToPetalsCount;
        mapping(address => mapping(uint256 => uint256)) private userOwnesPetals;       

        uint256 public fixedNFTAmount = 10;
        constructor() ERC721("Flower NFT", "Flower"){
               // _setBaseURI("https://gateway.pinata.cloud/ipfs/QmWF8jQYSLnqzYh5LqBVxR1RKNbPFBw77zmA8sRdChyA9t/");
        }

        function mintFlowerNFT(uint256 royaltyFee) public returns (uint256) {
                _tokenIdCounter.increment();
                uint256 newItemId = _tokenIdCounter.current();
                require(newItemId <= fixedNFTAmount,"Exceeds the minting Limit");

                _safeMint(msg.sender, newItemId, royaltyFee);
                
                userOwnesPetals[msg.sender][newItemId] += 1;
                _setTokenURI(newItemId, "1.json");
                
                return newItemId;
        }

        function upgradePetals(address to, uint256 id, uint256 _amount) external {
                userOwnesPetals[to][id] += _amount;
        }

        function balanceOfPetals(address to, uint256 nftId) public view returns(uint256){
                return userOwnesPetals[to][nftId];
        }        
}