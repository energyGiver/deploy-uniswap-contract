// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Radius.sol";

contract DeployRadius is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        Radius radius = new Radius(1000000 * 10 ** 18);
        console.log("Radius deployed at:", address(radius));
        vm.stopBroadcast();
    }
}
