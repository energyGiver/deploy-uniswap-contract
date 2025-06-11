// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/WETH.sol";

contract DeployWETH is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        WETH weth = new WETH(1000000 * 10 ** 18);
        console.log("WETH deployed at:", address(weth));
        vm.stopBroadcast();
    }
}
