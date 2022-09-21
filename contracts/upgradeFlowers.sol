// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./Interfaces/IFlowers.sol";
import "./Interfaces/IEnergyToken.sol";

contract upgrade {
    IFlowers public nftContract;
    IEnergyToken public tokenContract; 
    
    constructor(address _nftContract, address _tokenContract) {
            nftContract = IFlowers(_nftContract);
            tokenContract =IEnergyToken( _tokenContract);        
    }
    
    function upgradeFlowers(uint256 tokenId, uint256 energyTokenAmount) 
    public returns(uint256 upgradedpetals){    
        require(msg.sender == nftContract.ownerOf(tokenId),"You're not the owner of this token Id");
        require(energyTokenAmount >= 10,"Minimum amount is 10");

        uint256 energyBalace = tokenContract.balanceOf(msg.sender);
        require(energyBalace >= 10,"Insufficient Energy tokens");

        uint256 remainder = energyTokenAmount%10;
        uint256 energyBurnAmount = energyTokenAmount - remainder;
        uint256 petalAmount = energyTokenAmount/10;

        nftContract.upgradePetals(msg.sender, tokenId, petalAmount);

        tokenContract.burn(msg.sender, energyBurnAmount);

        upgradedpetals = nftContract.balanceOfPetals(msg.sender, tokenId);
    }
}
