// script/DeployV3Factory.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "forge-std/Script.sol";
import {UniswapV3Factory} from "lib/v3-core/contracts/UniswapV3Factory.sol";

contract DeployV3Factory is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        UniswapV3Factory factory = new UniswapV3Factory();

        console.log("UniswapV3Factory deployed:", address(factory));

        vm.stopBroadcast();
    }
}
