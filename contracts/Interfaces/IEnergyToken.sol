// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

interface IEnergyToken{
    function burn(address to, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}
