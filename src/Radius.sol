// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Radius is ERC20 {
    constructor(uint256 initialSupply) ERC20("Radius", "RDS") {
        _mint(msg.sender, initialSupply);
    }
}
