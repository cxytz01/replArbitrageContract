// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// https://github.com/Project-pFIL/pFIL-contracts/blob/main/contracts/Repl.sol#L17
interface IRepl {
    /**
     * @notice when user want to buy FIL with pFIL, the price unit is pFIL/FIL
     * @param _amount the amount of FIL want to buy
     * @param _id current auction id
     */ 
    function buy(uint _amount, uint _id) external;

    /**
     * @dev Price refers to how much pFIL is needed to exchange 1 FIL
     * @return current price of the FIL; pFIL / FIL
     */
    function getPrice() external view returns (uint);

    /**
     * auctionInfo getter
     */
    function auctionInfo() external view returns (uint, uint, uint, uint, uint);
}

// https://github.com/Project-pFIL/pFIL-contracts/blob/main/contracts/wPFIL.sol#L101
interface IWPFIL {
    /**
     * @notice Get amount of pFIL for one wpFIL
     * @return Amount of pFIL for 1 wpFIL
     */
    function PFILPerToken() external view returns (uint);
}

// https://github.com/Project-pFIL/pFIL-contracts/blob/main/contracts/periphery/UniswapSwapHelper.sol#L34
interface IUniswapSwapHelper {
    function swapToPFIL(uint minAmount, uint160 sqrtPriceLimitX96) external payable returns(uint);
}

// https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/pool/IUniswapV3PoolState.sol#L21
interface IUniswapV3PoolState {
     /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
     /// when accessed externally.
     /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
     /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
     /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
     /// boundary.
     /// observationIndex The index of the last oracle observation that was written,
     /// observationCardinality The current maximum number of observations stored in the pool,
     /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
     /// feeProtocol The protocol fee for both tokens of the pool.
     /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
     /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
     /// unlocked Whether the pool is currently locked to reentrancy
    function slot0() external view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

