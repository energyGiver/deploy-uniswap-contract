// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/UNI.sol";

contract DeployUNI is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        UNI uni = new UNI(1000000 * 10 ** 18);
        console.log("UNI deployed at:", address(uni));
        vm.stopBroadcast();
    }
}
