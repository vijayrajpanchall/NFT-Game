// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFlowers{
    function upgradePetals(address to, uint256 id, uint256 amount) external;

    function balanceOfPetals(address to, uint256 nftId) external view returns(uint256);
}