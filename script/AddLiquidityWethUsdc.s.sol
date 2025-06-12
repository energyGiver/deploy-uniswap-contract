// script/AddLiquidity_AllPairs.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/UniswapV3Liquidity.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract AddLiquidityWethUsdc is Script {
    // ── 토큰 주소 ─────────────────────────────────────────
    address constant WETH = 0x57f47C1F48b1078608f259B17D11f5ac925e5E04;
    address constant USDC = 0x9c85cd40541D67670aaC4D8249a55668896A6BD3;
    address constant UNI = 0xAC77A07dD1683DeA96c08F286b67783fB1e4B583;
    address constant RADIUS = 0xe61c0671DfC3036790F97dEf66b9d7C9a6b5C917;

    // ── 헬퍼 컨트랙트 주소(앞서 배포) ─────────────────────
    address constant LIQMGR = 0x875e1a0FA004EAb2d7B0767aeE07D8579a84cFFE;

    uint24 constant FEE = 3000; // 0.3 %
    uint160 constant SQRT_1_1 = uint160(2 ** 96); // 1 : 1  (≈ 7.92e28)

    // √가격 (Q = token1/token0)  ⇒  sqrt(Q)·2⁹⁶
    uint160 constant SQ_WETH_USDC = 0x03276b5238a6948698bfb75caf4b79dd;

    // uint160 constant SQ_WETH_USDC = 0x03276b5238a6948698bfb75caf4b79dd; // 2 800 USDC / WETH
    // uint160 constant SQ_WETH_UNI = 0x10bbb307acafdaead568979062; // 280  UNI  / WETH
    // uint160 constant SQ_WETH_RADIUS = 0x54a9fea74be3a6de39d4fcc3f; // 28   RADIUS/ WETH
    // uint160 constant SQ_USDC_UNI = 0x054e301b1329841107b1; // 0.1  UNI  / USDC
    // uint160 constant SQ_USDC_RADIUS = 0x01ad7f29abcaf485787a; // 0.01 RADIUS/ USDC
    // uint160 constant SQ_UNI_RADIUS = 0x050f44d8921243b6cdba25b3c; // 0.1  RADIUS/ UNI

    uint256 constant AMT_W = 1 ether;
    uint256 constant AMT_U = 2_800e6;

    function run() external {
        uint pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        IERC20(WETH).approve(LIQMGR, AMT_W);
        IERC20(USDC).approve(LIQMGR, AMT_U);

        UniswapV3Liquidity(LIQMGR).createAndAddLiquidity(
            WETH,
            USDC,
            FEE,
            AMT_W,
            AMT_U,
            SQ_WETH_USDC
        );
        vm.stopBroadcast();
    }
}
