// script/SwapRouter_WETH_USDC.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "lib/openzeppelin-contracts-old/contracts/token/ERC20/IERC20.sol";

contract SwapRouter_WETH_USDC is Script {
    // ────────── 상수 ───────────────────────────────────────
    address constant ROUTER = 0x405B626be44DEA7af49BB3E1De1341C60DfB0365;
    address constant WETH = 0x57f47C1F48b1078608f259B17D11f5ac925e5E04;
    address constant USDC = 0x9c85cd40541D67670aaC4D8249a55668896A6BD3;
    uint24 constant FEE = 3000; // 0.3 %

    uint256 constant AMOUNT_IN = 1e1; // 0.001 WETH

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        // 1) WETH → 라우터 approve
        IERC20(WETH).approve(ROUTER, AMOUNT_IN);

        // 2) exactInputSingle 호출
        ISwapRouter(ROUTER).exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: USDC,
                fee: FEE,
                recipient: msg.sender, // 내 지갑으로 USDC 수령
                deadline: block.timestamp + 10 minutes,
                amountIn: AMOUNT_IN,
                amountOutMinimum: 0, // Slippage 보호를 원하면 >0 로
                sqrtPriceLimitX96: 0 // 0 → 가격 제한 없음
            })
        );

        vm.stopBroadcast();

        console2.log("0.001 WETH swapped for USDC");
    }
}
