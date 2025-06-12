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

    function _roundToSpacing(
        int24 tick,
        int24 spacing,
        bool roundDown
    ) private pure returns (int24) {
        int24 rounded = (tick / spacing) * spacing; // Solidity truncates toward 0
        if (roundDown) {
            if (rounded > tick) rounded -= spacing; // 음수일 땐 더 작은 쪽
        } else {
            if (rounded < tick) rounded += spacing;
        }
        return rounded;
    }

    function createAndAddLiquidity(
        address tokenA,
        address tokenB,
        uint24 fee,
        uint256 amountA, // **wei 단위**
        uint256 amountB,
        uint160 sqrtPriceX96
    ) external {
        // ── 1. token 정렬 ────────────────────────────────
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        (uint256 amt0, uint256 amt1) = tokenA < tokenB
            ? (amountA, amountB)
            : (amountB, amountA);

        IERC20(token0).safeTransferFrom(msg.sender, address(this), amt0);
        IERC20(token1).safeTransferFrom(msg.sender, address(this), amt1);

        // ── 2. 풀 없으면 생성 + 초기화 ────────────────────
        IUniswapV3Factory f = IUniswapV3Factory(factory);
        address pool = f.getPool(token0, token1, fee);
        if (pool == address(0)) {
            pool = f.createPool(token0, token1, fee);
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            emit PoolCreated(pool);
        }

        // ── 3. tick 범위 spacing 에 맞추기 ────────────────
        int24 spacing = IUniswapV3Pool(pool).tickSpacing(); // int24!
        int24 tickLower = _roundToSpacing(TickMath.MIN_TICK, spacing, false); // -887 220
        int24 tickUpper = _roundToSpacing(TickMath.MAX_TICK, spacing, true); //  887 220

        // ── 4. 유동성 계산 & mint ────────────────────────
        uint128 liq = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            TickMath.getSqrtRatioAtTick(tickLower),
            TickMath.getSqrtRatioAtTick(tickUpper),
            amt0,
            amt1
        );

        IUniswapV3Pool(pool).mint(
            msg.sender,
            tickLower,
            tickUpper,
            liq,
            abi.encode(token0, token1)
        );

        emit LiquidityAdded(pool, liq);
    }

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
