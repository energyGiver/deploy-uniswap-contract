// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/USDC.sol";

contract DeployUSDC is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        USDC usdc = new USDC(1000000 * 10 ** 18);
        console.log("USDC deployed at:", address(usdc));
        vm.stopBroadcast();
    }
}
