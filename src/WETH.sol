// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    constructor(uint256 initialSupply) ERC20("Wrapped Ether", "WETH") {
        _mint(msg.sender, initialSupply);
    }
}
