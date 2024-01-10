// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbitrageBot is Ownable, ReentrancyGuard {
    error InvalidAddress(address _address);
    error InsufficientAmount();
    error YouWillGoingToLoseMoney();

    event Deposit(string func, address sender, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value, string token);
    event Arbitrage(uint filBeforeArbitrage, uint filAfterArbitrage);

    IUniswapSwapHelper public uniSwapHelper;
    IRepl public replAuction;
    IERC20 public pFIL;

    constructor(address _swapContract, address _replAuction, address _pFIL) Ownable(msg.sender) payable {
        if (_swapContract == address(0) || _replAuction == address(0) || _pFIL == address(0)) {
            revert InvalidAddress(address(0));
        }

        uniSwapHelper = IUniswapSwapHelper(_swapContract);
        replAuction = IRepl(_replAuction);
        pFIL = IERC20(_pFIL);
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
     * @notice call uniSwapHelper's function: swapToPFIL and replAuction's function auctionBidded in one transaction, make sure it is atomic. 
    */
    function arbitrageSwap(
        uint _minAmount,
        uint160 _sqrtPriceLimitX96,
        uint _FILamount,
        address _winner
    )
    external
    payable
    onlyOwner
    {
        if (msg.value >= _FILamount) {
            revert YouWillGoingToLoseMoney();
        }

        uint pFILAmount = uniSwapHelper.swapToPFIL(_minAmount, _sqrtPriceLimitX96);
        replAuction.auctionBidded(_FILamount, pFILAmount, _winner);

        emit Arbitrage(msg.value, _FILamount);
    }
}

