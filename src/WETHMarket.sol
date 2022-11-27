// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Owned} from "solmate/auth/Owned.sol";
import {WETH as IWETH} from "solmate/tokens/WETH.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

/// @dev WARNING: To be clear this repo is definitely a joke, WETH is a trustless wrapper, don't
/// give away your WETH for free, it's literally just ETH.
contract WETHMarket is Owned {
    using SafeTransferLib for IWETH;

    IWETH internal constant WETH = IWETH(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    uint256 internal constant RATE = 9500;
    uint256 internal constant MAX_BPS = 10000;

    receive() external payable {}

    constructor(address _initialOwner) Owned(_initialOwner) {}

    function swap(uint256 _amount) external {
        WETH.safeTransferFrom(msg.sender, address(this), _amount);
        WETH.withdraw(_amount);
        SafeTransferLib.safeTransferETH(msg.sender, (_amount * RATE) / MAX_BPS);
    }

    function withdraw(address _recipient) external onlyOwner {
        if (address(this).balance != 0) SafeTransferLib.safeTransferETH(_recipient, address(this).balance);
        uint256 wethBal = WETH.balanceOf(address(this));
        if (wethBal != 0) WETH.safeTransfer(_recipient, wethBal);
    }
}
