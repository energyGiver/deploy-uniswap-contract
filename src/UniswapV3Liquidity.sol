// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {TickMath} from "lib/v3-core/contracts/libraries/TickMath.sol";
import {SqrtPriceMath} from "lib/v3-core/contracts/libraries/SqrtPriceMath.sol";

contract UniswapV3Liquidity {
    using SafeERC20 for IERC20;

    // --- 상수 선언 ---
    // NonfungiblePositionManager 주소 (V3 기준이며, 롤업 환경에 맞게 수정 필요)
    address public constant POSITION_MANAGER =
        0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    // WETH 주소
    address public constant WETH = 0x529EB62Ae7B9791F34b7429E9c20313CD48927F4;

    // --- 이벤트 ---
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        address pool
    );
    event LiquidityAdded(address indexed pool, uint256 liquidity);

    // --- 함수 ---

    /**
     * @notice 두 토큰과 수수료 등급을 받아 유니스왑 V3 풀을 생성하고 초기 유동성을 공급합니다.
     * @param _tokenA 주소: 첫 번째 토큰의 주소
     * @param _tokenB 주소: 두 번째 토큰의 주소
     * @param _fee 수수료 등급 (예: 3000 for 0.3%)
     * @param _amountA 원하는 첫 번째 토큰의 유동성 공급량
     * @param _amountB 원하는 두 번째 토큰의 유동성 공급량
     * @param _sqrtPriceX96 초기 가격 설정을 위한 SqrtPriceX96 값
     */
    function createAndAddLiquidity(
        address _tokenA,
        address _tokenB,
        uint24 _fee,
        uint256 _amountA,
        uint256 _amountB,
        uint160 _sqrtPriceX96
    ) external {
        // 토큰 전송 권한 위임 (Approve)
        IERC20(_tokenA).safeApprove(POSITION_MANAGER, _amountA);
        IERC20(_tokenB).safeApprove(POSITION_MANAGER, _amountB);

        // NonfungiblePositionManager 인터페이스
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(
                POSITION_MANAGER
            );

        // 풀 생성 및 초기화
        address pool = positionManager.createAndInitializePoolIfNecessary(
            _tokenA,
            _tokenB,
            _fee,
            _sqrtPriceX96
        );

        emit PoolCreated(_tokenA, _tokenB, _fee, pool);

        // 유동성 공급 (Mint)
        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: _tokenA,
                token1: _tokenB,
                fee: _fee,
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                amount0Desired: _amountA,
                amount1Desired: _amountB,
                amount0Min: 0,
                amount1Min: 0,
                recipient: msg.sender,
                deadline: block.timestamp
            });

        (, , uint256 liquidity, , ) = positionManager.mint(params);

        emit LiquidityAdded(pool, liquidity);
    }
}
