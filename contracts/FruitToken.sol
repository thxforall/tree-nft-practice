// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FruitToken is ERC20, Ownable {
    address public minter;

    constructor() ERC20("Fruit Token", "FRUIT") Ownable(msg.sender) {}

    function setMiner(address _minter) external onlyOwner {
        minter = _minter;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter can do this");
        _;
    }

    function mint(address to, uint amount) external onlyMinter {
        _mint(to, amount);
    }
}