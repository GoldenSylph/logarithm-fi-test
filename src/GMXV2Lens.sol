// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract GMXV2Lens {
    struct MarketDataState {
        address marketToken;
        address indexToken;
        address longToken;
        address shortToken;
        uint256 poolValue; // 30 decimals
        uint256 longTokenAmount; // token decimals
        uint256 longTokenUsd; // 30 decimals
        uint256 shortTokenAmount; // token decimals
        uint256 shortTokenUsd; // 30 decimals
        int256 openInterestLong; // 30 decimals
        int256 openInterestShort; // 30 decimals
        int256 pnlLong; // 30 decimals
        int256 pnlShort; // 30 decimals
        int256 netPnl; // 30 decimals
        uint256 borrowingFactorPerSecondForLongs; // 30 decimals
        uint256 borrowingFactorPerSecondForShorts; // 30 decimals
        bool longsPayShorts;
        uint256 fundingFactorPerSecond; // 30 decimals
        int256 fundingFactorPerSecondLongs; // 30 decimals
        int256 fundingFactorPerSecondShorts; // 30 decimals
        uint256 reservedUsdLong; // 30 decimals
        uint256 reservedUsdShort; // 30 decimals
        uint256 maxOpenInterestUsdLong; // 30 decimals
        uint256 maxOpenInterestUsdShort; // 30 decimals
    }

    function getMarketData(address marketID) external view returns (MarketDataState memory) {

    }
}
