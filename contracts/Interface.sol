// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRepl {
    function auctionBidded(uint256 _FILamount, uint256 _pFILAmount, address _winner) external;
}

interface IUniswapSwapHelper {
    function swapToPFIL(uint minAmount, uint160 sqrtPriceLimitX96) external payable returns(uint);
}

