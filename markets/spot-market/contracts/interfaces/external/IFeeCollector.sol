//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Spot Market Interface
interface IFeeCollector {
    function collectFee(uint256 feeAmount) external returns (uint feesCollected);
}
