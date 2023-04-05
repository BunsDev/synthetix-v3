//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "../storage/OrderFees.sol";

/**
 * @title Module for atomic buy and sell orders for traders.
 */
interface IAtomicOrderModule {
    /**
     * @notice Thrown when trade is charging more USD than the max amount specified by the trader.
     * @dev Used in buyExactOut
     */
    error ExceedsMaxUsdAmount(uint maxUsdAmount, uint usdAmountCharged);
    /**
     * @notice Thrown when trade is charging more synth than the max amount specified by the trader.
     * @dev Used in sellExactOut
     */
    error ExceedsMaxSynthAmount(uint maxSynthAmount, uint synthAmountCharged);
    /**
     * @notice Thrown when a trade doesn't meet minimum expected return amount.
     */
    error InsufficientAmountReceived(uint expected, uint current);

    /**
     * @notice Gets fired when buy trade is complete
     * @param synthMarketId Id of the market used for the trade.
     * @param synthReturned Synth received on the trade based on amount provided by trader.
     * @param fees breakdown of all fees incurred for transaction.
     * @param collectedFees Fees collected by the configured FeeCollector for the market (rest of the fees are deposited to market manager).
     * @param referrer Optional address of the referrer, for fee share
     */
    event SynthBought(
        uint indexed synthMarketId,
        uint synthReturned,
        OrderFees.Data fees,
        uint collectedFees,
        address referrer
    );

    /**
     * @notice Gets fired when buy trade is complete
     * @param synthMarketId Id of the market used for the trade.
     * @param amountReturned Amount of snxUSD returned to user based on synth provided by trader.
     * @param fees breakdown of all fees incurred for transaction.
     * @param collectedFees Fees collected by the configured FeeCollector for the market (rest of the fees are deposited to market manager).
     * @param referrer Optional address of the referrer, for fee share
     */
    event SynthSold(
        uint indexed synthMarketId,
        uint amountReturned,
        OrderFees.Data fees,
        uint collectedFees,
        address referrer
    );

    /**
     * @notice Initiates a buy trade returning synth for the specified amountUsd.
     * @dev Transfers the specified amountUsd, collects fees through configured fee collector, returns synth to the trader.
     * @dev Leftover fees not collected get deposited into the market manager to improve market PnL.
     * @dev Uses the buyFeedId configured for the market.
     * @param synthMarketId Id of the market used for the trade.
     * @param amountUsd Amount of snxUSD trader is providing allownace to for the trade.
     * @param minAmountReceived Min Amount of synth is expected the trader to receive otherwise the transaction will revert.
     * @param referrer Optional address of the referrer, for fee share
     * @return synthReturned Synth received on the trade based on amount provided by trader.
     * @return fees breakdown of all the fees incurred for the transaction.
     */
    function buyExactIn(
        uint128 synthMarketId,
        uint amountUsd,
        uint minAmountReceived,
        address referrer
    ) external returns (uint, OrderFees.Data memory);

    /**
     * @notice  alias for buyExactIn
     * @param   marketId  (see buyExactIn)
     * @param   usdAmount  (see buyExactIn)
     * @param   minAmountReceived  (see buyExactIn)
     * @param   referrer  (see buyExactIn)
     * @return  synthAmount  (see buyExactIn)
     * @return  fees  (see buyExactIn)
     */
    function buy(
        uint128 marketId,
        uint usdAmount,
        uint minAmountReceived,
        address referrer
    ) external returns (uint synthAmount, OrderFees.Data memory fees);

    /**
     * @notice  user provides the synth amount they'd like to buy, and the function charges the USD amount which includes fees
     * @dev     the inverse of buyExactIn
     * @param   synthMarketId  market id value
     * @param   synthAmount  the amount of synth the trader wants to buy
     * @param   maxUsdAmount  max amount the trader is willing to pay for the specified synth
     * @param   referrer  optional address of the referrer, for fee share
     * @return  uint  amount of USD charged for the trade
     * @return  OrderFees.Data  breakdown of all the fees incurred for the transaction
     */
    function buyExactOut(
        uint128 synthMarketId,
        uint synthAmount,
        uint maxUsdAmount,
        address referrer
    ) external returns (uint, OrderFees.Data memory);

    /**
     * @notice  quote for buyExactIn.  same parameters and return values as buyExactIn
     * @param   synthMarketId  market id value
     * @param   usdAmount  amount of USD to use for the trade
     * @return  synthAmount  return amount of synth given the USD amount - fees
     * @return  OrderFees.Data  breakdown of all the quoted fees for the buy txn
     */
    function quoteBuyExactIn(
        uint128 synthMarketId,
        uint usdAmount
    ) external view returns (uint256 synthAmount, OrderFees.Data memory);

    /**
     * @notice  quote for buyExactOut.  same parameters and return values as buyExactOut
     * @param   synthMarketId  market id value
     * @param   synthAmount  amount of synth requested
     * @return  usdAmountCharged  USD amount charged for the synth requested - fees
     * @return  OrderFees.Data  breakdown of all the quoted fees for the buy txn
     */
    function quoteBuyExactOut(
        uint128 synthMarketId,
        uint synthAmount
    ) external view returns (uint256 usdAmountCharged, OrderFees.Data memory);

    /**
     * @notice Initiates a sell trade returning snxUSD for the specified amount of synth (sellAmount)
     * @dev Transfers the specified synth, collects fees through configured fee collector, returns snxUSD to the trader.
     * @dev Leftover fees not collected get deposited into the market manager to improve market PnL.
     * @param synthMarketId Id of the market used for the trade.
     * @param sellAmount Amount of synth provided by trader for trade into snxUSD.
     * @param minAmountReceived Min Amount of snxUSD trader expects to receive for the trade
     * @param referrer Optional address of the referrer, for fee share
     * @return amountReturned Amount of snxUSD returned to user
     * @return fees breakdown of all the fees incurred for the transaction.
     */
    function sellExactIn(
        uint128 synthMarketId,
        uint sellAmount,
        uint minAmountReceived,
        address referrer
    ) external returns (uint, OrderFees.Data memory);

    /**
     * @notice  initiates a trade where trader specifies USD amount they'd like to receive
     * @dev     the inverse of sellExactIn
     * @param   marketId  synth market id
     * @param   usdAmount  amount of USD trader wants to receive
     * @param   maxSynthAmount  max amount of synth trader is willing to use to receive the specified USD amount
     * @param   referrer  optional address of the referrer, for fee share
     * @return  synthAmount amount of synth charged
     * @return  OrderFees.Data  breakdown of all the fees incurred for the transaction
     */
    function sellExactOut(
        uint128 marketId,
        uint usdAmount,
        uint maxSynthAmount,
        address referrer
    ) external returns (uint synthAmount, OrderFees.Data memory);

    /**
     * @notice  alias for sellExactIn
     * @param   marketId  (see sellExactIn)
     * @param   synthAmount  (see sellExactIn)
     * @param   minUsdAmount  (see sellExactIn)
     * @param   referrer  (see sellExactIn)
     * @return  usdAmountReceived  (see sellExactIn)
     * @return  fees  (see sellExactIn)
     */
    function sell(
        uint128 marketId,
        uint synthAmount,
        uint minUsdAmount,
        address referrer
    ) external returns (uint usdAmountReceived, OrderFees.Data memory fees);

    /**
     * @notice  quote for sellExactIn
     * @dev     returns expected USD amount trader would receive for the specified synth amount
     * @param   marketId  synth market id
     * @param   synthAmount  synth amount trader is providing for the trade
     * @return  returnAmount  amount of USD expected back
     * @return  OrderFees.Data  breakdown of all the quoted fees for the txn
     */
    function quoteSellExactIn(
        uint128 marketId,
        uint synthAmount
    ) external view returns (uint256 returnAmount, OrderFees.Data memory);

    /**
     * @notice  quote for sellExactOut
     * @dev     returns expected synth amount expected from trader for the requested USD amount
     * @param   marketId  synth market id
     * @param   usdAmount  USD amount trader wants to receive
     * @return  synthAmount  amount of synth expected from trader
     * @return  OrderFees.Data  breakdown of all the quoted fees for the txn
     */
    function quoteSellExactOut(
        uint128 marketId,
        uint usdAmount
    ) external view returns (uint256 synthAmount, OrderFees.Data memory);
}
