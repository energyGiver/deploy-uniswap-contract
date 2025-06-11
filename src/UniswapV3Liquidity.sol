// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ── OpenZeppelin v5.3.0 ──────────────────────────────────────────
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

// ── Uniswap v3 core + periphery ─────────────────────────────────
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {LiquidityAmounts} from "@uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol";

contract UniswapV3Liquidity {
    using SafeERC20 for IERC20;

    address public immutable factory;

    event PoolCreated(address pool);
    event LiquidityAdded(address pool, uint128 liquidity);

    constructor(address _factory) {
        factory = _factory;
    }

    /// @notice 풀이 없으면 만들고, 전구간(tick MIN~MAX)에 유동성을 넣는다
    function createAndAddLiquidity(
        address tokenA,
        address tokenB,
        uint24 fee,
        uint256 amountA,
        uint256 amountB,
        uint160 sqrtPriceX96
    ) external {
        // ── 토큰 정렬 ──────────────────────────────────────────────
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        (uint256 amount0, uint256 amount1) = tokenA < tokenB
            ? (amountA, amountB)
            : (amountB, amountA);

        // ── 토큰 보관 ──────────────────────────────────────────────
        IERC20(token0).safeTransferFrom(msg.sender, address(this), amount0);
        IERC20(token1).safeTransferFrom(msg.sender, address(this), amount1);

        // ── 풀 생성 & 초기화 ───────────────────────────────────────
        IUniswapV3Factory f = IUniswapV3Factory(factory);
        address pool = f.getPool(token0, token1, fee);
        if (pool == address(0)) {
            pool = f.createPool(token0, token1, fee);
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            emit PoolCreated(pool);
        }

        // ── 유동성 계산 ───────────────────────────────────────────
        int24 tickLower = TickMath.MIN_TICK;
        int24 tickUpper = TickMath.MAX_TICK;

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            TickMath.getSqrtRatioAtTick(tickLower),
            TickMath.getSqrtRatioAtTick(tickUpper),
            amount0,
            amount1
        );

        // ── mint (풀에서 callback 호출) ───────────────────────────
        IUniswapV3Pool(pool).mint(
            msg.sender,
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(token0, token1) // callback data
        );

        emit LiquidityAdded(pool, liquidity);
    }

    /// @dev 풀에서 호출. 이 컨트랙트가 풀에 토큰을 전송해 줘야 한다.
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external {
        (address token0, address token1) = abi.decode(data, (address, address));

        if (amount0Owed > 0)
            IERC20(token0).safeTransfer(msg.sender, amount0Owed);
        if (amount1Owed > 0)
            IERC20(token1).safeTransfer(msg.sender, amount1Owed);
    }
}
