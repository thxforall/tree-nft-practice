// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IFruitToken {
    function mint(address to, uint256 amount) external;
}

contract TreeNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;
    IFruitToken public fruitToken;
    mapping(uint256 => uint256) public lastClaimTime;

    // One day - 86400
    uint256 constant REWARD_INTERVAL = 120;

    constructor(address _fruitTokenAddress)
        ERC721("Tree NFT", "TREE")
        Ownable(msg.sender)
    {
        tokenCounter = 0;
        fruitToken = IFruitToken(_fruitTokenAddress);
    }

    function mintNFT(string memory tokenURI) external {
        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        lastClaimTime[tokenId] = block.timestamp;

        tokenCounter++;
    }

    function claimRewards(uint256[] calldata tokenIds) external {
        uint256 totalReward = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                ownerOf(tokenIds[i]) == msg.sender,
                "Caller is not NFT owner."
            );

            uint256 lastTime = lastClaimTime[tokenIds[i]];
            uint256 daysPassed = (block.timestamp - lastTime) / REWARD_INTERVAL;

            if (daysPassed > 0) {
                totalReward += daysPassed;
                lastClaimTime[tokenIds[i]] = lastTime + daysPassed * REWARD_INTERVAL;
            }
        }
        require(totalReward > 0, "No rewards available");
        fruitToken.mint(msg.sender, totalReward * 1e18);
    }
}
