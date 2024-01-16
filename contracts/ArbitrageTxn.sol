// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ArbitrageBot is Ownable {
    error InvalidAddress(address _address);
    error InsufficientAmount();
    error YouWillGoingToLoseMoney();

    event Deposit(string func, address sender, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value, string token);
    event Arbitrage(address indexed from, uint minpFilWantToSwap, uint pFilSwap, uint filBidded);

    IUniswapV3PoolState public uniswapPool;
    IUniswapSwapHelper public uniSwapHelper;
    IRepl public replAuction;
    IERC20 public pFIL;
    IWPFIL public wpFIL;
    // uint8 public profitRate;

    constructor(address _swapContract, address _replAuction, address _pFIL, address _wpFIL, address _uniswapPool) Ownable(msg.sender) payable {
        if (_swapContract == address(0) || _replAuction == address(0) || _pFIL == address(0)) {
            revert InvalidAddress(address(0));
        }

        uniSwapHelper = IUniswapSwapHelper(_swapContract);
        replAuction = IRepl(_replAuction);
        pFIL = IERC20(_pFIL);
        wpFIL = IWPFIL(_wpFIL);
        uniswapPool = IUniswapV3PoolState(_uniswapPool);
    }

    fallback() external payable {
        emit Deposit("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Deposit("receive", msg.sender, msg.value, "");
    }

    /**
     * @notice withdrawFIL to the owner
     */
    function withdrawFIL(uint _amount) external onlyOwner {
        if (address(this).balance < _amount) {
            revert InsufficientAmount();
        }

        payable(owner()).transfer(_amount);

        emit Transfer(address(this), owner(), _amount, "FIL");
    }

    /**
     * @notice withdralPFIL to the owner
     */
    function withdrawPFIL(uint _amount) external onlyOwner {
        if (pFIL.balanceOf(msg.sender) < _amount) {
            revert InsufficientAmount();
        }

        pFIL.transfer(owner(), _amount);

        emit Transfer(address(this), owner(), _amount, "PFIL");
    }

    /**
     * @notice getOwnerBalance, return both FIL and pFIL 
     * @return FILAmount 
     * @return pFILAmount 
     */
    function getOwnerBalance() external view returns (uint FILAmount, uint pFILAmount) {
        FILAmount = address(this).balance;
        pFILAmount = pFIL.balanceOf(owner());
    }

    /**
     * @notice get FIL/pFIL pair from uniswap and repl 
     * @return uniswapPair
     * @return replPair 
     */
    function getPairPrice() public view returns (uint uniswapPair, uint replPair) {
        // get pool price FIL/pFIL
        (uniswapPair,) = getPoolPrice();

        // get auction price FIL/pFIL
        replPair = getAuctionPrice();
    }
  
    /**
     * @notice call uniSwapHelper's function: swapToPFIL and replAuction's function auctionBidded in one transaction, make sure it is atomic. 
    */
    function arbitrageSwap(
        uint _minPFILToSwap,
        uint _FILamount
    )
    external
    payable
    onlyOwner
    {
        (uint uniswapPoolPair,uint replPair) = getPairPrice();
        if (uniswapPoolPair >= replPair) {
            revert YouWillGoingToLoseMoney();
        }

        uint pFILAmount = uniSwapHelper.swapToPFIL{value: msg.value}(_minPFILToSwap, 0, 0);
        (,,,,uint auctionId) = replAuction.auctionInfo();
        replAuction.buy(_FILamount, auctionId);

        if (msg.value <= _FILamount) {
            revert YouWillGoingToLoseMoney();
        }

        emit Arbitrage(msg.sender, _minPFILToSwap, pFILAmount, _FILamount);
    }

    /**
     * @notice get FIL/pFIL from uniswap pool
     * https://github.com/Project-pFIL/pFIL-contracts/blob/feat/arbitrage-helper/scripts/arbitrage-helper.ts#L18 
     */
    function getPoolPrice() internal view returns (uint, uint160) {
        (uint160 sqrtPriceX96, , , , , ,) = uniswapPool.slot0();
        uint pFILperwpFIL_BN = wpFIL.PFILPerToken();
        // https://ethereum.stackexchange.com/questions/98685/computing-the-uniswap-v3-pair-price-from-q64-96-number
        return ((pFILperwpFIL_BN*1e18)/(uint(sqrtPriceX96)*(uint(sqrtPriceX96))*(1e18) >> (96 * 2)), sqrtPriceX96);
    }

    /**
     * @notice get FIL/pFIL from repl auction
     * https://github.com/Project-pFIL/pFIL-contracts/blob/feat/arbitrage-helper/scripts/arbitrage-helper.ts#L27
     */
    function getAuctionPrice() internal view returns (uint) {
        return replAuction.getPrice();
    }
}

