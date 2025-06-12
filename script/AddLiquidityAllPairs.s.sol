// script/AddLiquidity_AllPairs.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/UniswapV3Liquidity.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract AddLiquidityAllPairs is Script {
    // ── 토큰 주소 ─────────────────────────────────────────
    address constant WETH = 0x57f47C1F48b1078608f259B17D11f5ac925e5E04;
    address constant USDC = 0x9c85cd40541D67670aaC4D8249a55668896A6BD3;
    address constant UNI = 0xAC77A07dD1683DeA96c08F286b67783fB1e4B583;
    address constant RADIUS = 0xe61c0671DfC3036790F97dEf66b9d7C9a6b5C917;

    // ── 헬퍼 컨트랙트 주소(앞서 배포) ─────────────────────
    address constant LIQMGR = 0x0dd69ED9C187D537D03D34A98aa5277ED5F7f7F8;

    uint24 constant FEE = 3000; // 0.3 %
    uint160 constant SQRT_1_1 = uint160(2 ** 96); // 1 : 1  (≈ 7.92e28)

    // √가격 (Q = token1/token0)  ⇒  sqrt(Q)·2⁹⁶
    uint160 constant SQ_WETH_USDC = 0x03276b5238a6948698bfb75caf4b79dd; // 2 800 USDC / WETH
    uint160 constant SQ_WETH_UNI = 0x10bbb307acafdaead568979062; // 280  UNI  / WETH
    uint160 constant SQ_WETH_RADIUS = 0x54a9fea74be3a6de39d4fcc3f; // 28   RADIUS/ WETH
    uint160 constant SQ_USDC_UNI = 0x054e301b1329841107b1; // 0.1  UNI  / USDC
    uint160 constant SQ_USDC_RADIUS = 0x01ad7f29abcaf485787a; // 0.01 RADIUS/ USDC
    uint160 constant SQ_UNI_RADIUS = 0x050f44d8921243b6cdba25b3c; // 0.1  RADIUS/ UNI

    struct Pair {
        address tokenA;
        address tokenB;
        uint160 sqrtP;
        uint256 amtA;
        uint256 amtB;
    }

    // storage-mapping 허용
    mapping(address => uint256) private totals;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        Pair[6] memory P = [
            Pair(WETH, USDC, SQ_WETH_USDC, 1 ether, 2_800 ether),
            Pair(WETH, UNI, SQ_WETH_UNI, 1 ether, 280 ether),
            Pair(WETH, RADIUS, SQ_WETH_RADIUS, 1 ether, 28 ether),
            Pair(USDC, UNI, SQ_USDC_UNI, 10 ether, 1 ether),
            Pair(USDC, RADIUS, SQ_USDC_RADIUS, 100 ether, 1 ether),
            Pair(UNI, RADIUS, SQ_UNI_RADIUS, 10 ether, 1 ether)
        ];

        // 1) 토큰별 총량
        for (uint i; i < P.length; ++i) {
            totals[P[i].tokenA] += P[i].amtA;
            totals[P[i].tokenB] += P[i].amtB;
        }

        // 2) allowance 한 번씩
        address[4] memory TOKENS = [WETH, USDC, UNI, RADIUS];
        for (uint j; j < TOKENS.length; ++j) {
            IERC20(TOKENS[j]).approve(LIQMGR, totals[TOKENS[j]]);
        }

        // 3) 6개 풀+LP
        for (uint i; i < P.length; ++i) {
            UniswapV3Liquidity(LIQMGR).createAndAddLiquidity(
                P[i].tokenA,
                P[i].tokenB,
                FEE,
                P[i].amtA,
                P[i].amtB,
                P[i].sqrtP
            );
        }

        vm.stopBroadcast();
    }
}
