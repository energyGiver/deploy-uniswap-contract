// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "forge-std/interfaces/IERC20.sol";

contract AddLiquidityWethUsdcNFPM is Script {
    // =========================================================================
    //                                 설정 값
    // =========================================================================

    // 롤업에 배포된 NonfungiblePositionManager(NFPM)의 주소
    address constant NFPM_ADDRESS = 0xE31D957c46DFFd0f6179c9DAb7779ccB725770ee; // <<-- 본인의 NFPM 주소로 반드시 변경하세요!!

    // 롤업에 배포된 Factory 주소 (NFPM 배포 시 사용했던 주소)
    address constant FACTORY_ADDRESS =
        0xE4403F9Da76D9b64823175389EFb5205469eB139; // <<-- 본인의 Factory 주소로 변경하세요!!

    // 토큰 주소
    address constant WETH_ADDRESS = 0x57f47C1F48b1078608f259B17D11f5ac925e5E04;
    address constant USDC_ADDRESS = 0x9c85cd40541D67670aaC4D8249a55668896A6BD3;

    // 유동성 풀의 수수료 (0.3%)
    uint24 constant POOL_FEE = 3000;

    // =========================================================================
    //                            메인 실행 함수
    // =========================================================================
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(pk);

        // ======================= 값 수정 =======================
        // 1. 공급할 유동성 양 정의 (USDC decimals 수정)
        uint256 amountWethDesired = 0.5 ether; // 0.5 WETH (18 decimals)
        uint256 amountUsdcDesired = 2000 * 1 ether; // 2000 USDC (18 decimals) - 이제 올바른 값입니다!

        // 2. 시작 가격 설정 (새로운 sqrtPriceX96 값)
        uint160 initialSqrtPrice = 50100816343219854710499584;

        // ========================================================

        // 토큰 주소 정렬
        (address token0, address token1) = WETH_ADDRESS < USDC_ADDRESS
            ? (WETH_ADDRESS, USDC_ADDRESS)
            : (USDC_ADDRESS, WETH_ADDRESS);

        (uint256 amount0Desired, uint256 amount1Desired) = WETH_ADDRESS <
            USDC_ADDRESS
            ? (amountWethDesired, amountUsdcDesired)
            : (amountUsdcDesired, amountWethDesired);

        vm.startBroadcast(pk);

        // 헬퍼 함수 호출
        _provideLiquidity(
            user,
            token0,
            token1,
            amount0Desired,
            amount1Desired,
            initialSqrtPrice
        );

        vm.stopBroadcast();

        // 결과 확인
        INonfungiblePositionManager nfpm = INonfungiblePositionManager(
            NFPM_ADDRESS
        );
        console.log("\n--- Liquidity Provision Attempted ---");
        console.log("Your NFT Position Balance:", nfpm.balanceOf(user));
    }

    function _provideLiquidity(
        address user,
        address token0,
        address token1,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint160 initialSqrtPrice
    ) internal {
        // ... (헬퍼 함수 내용은 이전과 동일하게 유지)
        INonfungiblePositionManager nfpm = INonfungiblePositionManager(
            NFPM_ADDRESS
        );
        IUniswapV3Factory factory = IUniswapV3Factory(nfpm.factory());

        IERC20(token0).approve(NFPM_ADDRESS, type(uint256).max);
        IERC20(token1).approve(NFPM_ADDRESS, type(uint256).max);

        nfpm.createAndInitializePoolIfNecessary(
            token0,
            token1,
            POOL_FEE,
            initialSqrtPrice
        );

        address poolAddress = factory.getPool(token0, token1, POOL_FEE);

        int24 tickSpacing = IUniswapV3Pool(poolAddress).tickSpacing();
        int24 tickLower = (TickMath.MIN_TICK / tickSpacing) * tickSpacing;
        int24 tickUpper = (TickMath.MAX_TICK / tickSpacing) * tickSpacing;

        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: POOL_FEE,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                recipient: user,
                deadline: block.timestamp
            });

        nfpm.mint(params);
    }
}
