// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Token/ERC721.sol";
import "./Interfaces/IFlowers.sol";
import "./Interfaces/IEnergyToken.sol";

contract flowers is ERC721, IFlowers, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    IEnergyToken tokenContract;

    mapping(address => mapping(uint256 => uint256)) private userOwnesPetals;
    mapping(address => bool) private whitelistedByOwner;

    //Hardcoded this Because only 10 Images stored on pinata
    uint256 public constant maxNFTAmount = 10;
    uint256 public perPetalEnergyRequired = 10; //for upgrade petals
    
    constructor() ERC721("Flower NFT", "Flower") {
        _setBaseURI(
            "https://gateway.pinata.cloud/ipfs/QmWF8jQYSLnqzYh5LqBVxR1RKNbPFBw77zmA8sRdChyA9t/"
        );
    }

    //Modifier - only selected user and owner can mint these NFTs
    modifier mintingPermission() {
        require(
            whitelistedByOwner[msg.sender] == true || msg.sender == owner(),
            "Not Owner or Not Whitelisted by Owner"
        );
        _;
    }

    /**
     * owner and some selected user can mint flower NFTs.
     * Initially every flower have 1 attached petal.
     * Max minting NFT amount is specified.
     * Maintaining token URI for each token
     */

    function mintFlowerNFT() public mintingPermission returns (uint256) {
        _tokenIdCounter.increment();
        uint256 newItemId = _tokenIdCounter.current();
        require(newItemId <= maxNFTAmount, "Exceeds the minting Limit");

        _safeMint(msg.sender, newItemId);

        userOwnesPetals[msg.sender][newItemId] = 1;
        uint256 petals = userOwnesPetals[msg.sender][newItemId];

        emit FlowerMinted(msg.sender, newItemId, petals);

        return newItemId;
    }

    /**owner can allow some users for minting NFTs */
    function whitelistUser(address user) public onlyOwner {
        whitelistedByOwner[user] = true;
    }

    /**changePerPetalEnergyRequired function can change default energy required
     * for upgrading petals of a flower NFT.
     * only owner can change it.
     */

    function changePerPetalEnergyRequired(uint256 newValue)
        public
        onlyOwner
        returns (uint256)
    {
        perPetalEnergyRequired = newValue;
        return perPetalEnergyRequired;
    }
    /**
     * If user have a sufficient amount of Energy token then can feed those Energy
     * token to Flower to upgrade the flower(Increase the number of petals)
     */
    function upgradeFlowers(
        uint256 tokenId,
        IEnergyToken _tokenContract,
        uint256 energyTokenAmount
    ) public returns (uint256 upgradedpetals) {
        tokenContract = _tokenContract;
        require(
            msg.sender == ownerOf(tokenId),
            "You're not the owner of this token Id"
        );
        require(
            energyTokenAmount >= perPetalEnergyRequired,
            "Providing less energy tokens"
        );

        uint256 energyBalace = tokenContract.balanceOf(msg.sender);
        require(
            energyBalace >= perPetalEnergyRequired,
            "Insufficient Energy tokens"
        );

        uint256 remainder = energyTokenAmount % perPetalEnergyRequired;
        uint256 energyBurnAmount = energyTokenAmount - remainder;
        uint256 petalAmount = energyTokenAmount / perPetalEnergyRequired;

        userOwnesPetals[msg.sender][tokenId] += petalAmount;

        tokenContract.burn(msg.sender, energyBurnAmount);

        upgradedpetals = balanceOfPetals(msg.sender, tokenId);

        emit PetalsUpgraded(msg.sender, tokenId, petalAmount);
    }

    //_beforeTokenTransfer this internal function helps to send petals to the "to"
    //address when a user transfer NFT token
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        uint256 petals = userOwnesPetals[from][tokenId];
        delete userOwnesPetals[from][tokenId];
        userOwnesPetals[to][tokenId] += petals;
    }
    /**
     * @return Petal balance of a token Id 
     */
    function balanceOfPetals(address to, uint256 nftId)
        public
        view
        returns (uint256)
    {
        return userOwnesPetals[to][nftId];
    }
}
