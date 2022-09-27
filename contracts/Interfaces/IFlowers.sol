// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IFlowers is IERC721{
    event FlowerMinted(
        address indexed owner, 
        uint256 indexed tokenId,  
        uint256 petals
        );
        
    event PetalsUpgraded(
        address indexed account,
        uint256 indexed tokenId,
        uint256 petalsAmount
        );
}