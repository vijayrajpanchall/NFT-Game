// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IEnergyToken is IERC20 {

    function mint(address to, uint256 amount) external;

    function burn(address to, uint256 amount) external;
}
