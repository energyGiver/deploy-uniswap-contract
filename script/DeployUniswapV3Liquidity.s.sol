// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/UniswapV3Liquidity.sol";

contract DeployUniswapV3Liquidity is Script {
    // ── 이미 배포해 둔 Factory 주소 입력 ──
    address constant FACTORY = 0xE4403F9Da76D9b64823175389EFb5205469eB139;

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        UniswapV3Liquidity liq = new UniswapV3Liquidity(FACTORY);

        console2.log("UniswapV3Liquidity deployed at:", address(liq));

        vm.stopBroadcast();
    }
}
