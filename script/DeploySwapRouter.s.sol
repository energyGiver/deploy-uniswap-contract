// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "forge-std/Script.sol";
import "lib/v3-periphery/contracts/SwapRouter.sol";

contract DeploySwapRouter is Script {
    // 롤업에 배포된 Uniswap V3 Factory 주소
    // UniswapV3Liquidity 컨트랙트에 사용했던 Factory 주소와 동일해야 합니다.
    address private constant YOUR_FACTORY_ADDRESS =
        0xE4403F9Da76D9b64823175389EFb5205469eB139; // 본인의 Factory 주소로 변경

    // 롤업에 배포된 WETH 컨트랙트 주소
    address private constant YOUR_WETH_ADDRESS =
        0x57f47C1F48b1078608f259B17D11f5ac925e5E04; // 본인의 WETH 주소로 변경

    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // SwapRouter 배포
        SwapRouter swapRouter = new SwapRouter(
            YOUR_FACTORY_ADDRESS,
            YOUR_WETH_ADDRESS
        );

        vm.stopBroadcast();

        address deployedAddress = address(swapRouter);
        console.log("SwapRouter deployed at:", deployedAddress);

        return deployedAddress;
    }
}
