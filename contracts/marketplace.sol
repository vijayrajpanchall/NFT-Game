// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
contract marketplace{
    IERC20 public tokenContract;
    IERC721 public nftContract;
    constructor(address _tokenContract, address _nftContract){
        tokenContract = IERC20(_tokenContract);
        nftContract = IERC721(_nftContract);
    }

    function sellNFT() 
}