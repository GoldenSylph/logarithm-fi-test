// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@gmx-io/synthetics/market/Market.sol";
import "@gmx-io/synthetics/market/MarketUtils.sol";
import "@gmx-io/synthetics/market/MarketPoolValueInfo.sol";

import "@gmx-io/synthetics/data/DataStore.sol";
import "@gmx-io/synthetics/data/Keys.sol";

import "@gmx-io/synthetics/reader/Reader.sol";
import "@gmx-io/synthetics/oracle/Oracle.sol";

contract GMXV2Lens is UUPSUpgradeable {
    struct MarketDataState {
        address marketToken; // +
        address indexToken; // +
        address longToken; // +
        address shortToken; // +

        uint256 poolValue; // 30 decimals + 
        
        uint256 longTokenAmount; // token decimals + 
        uint256 longTokenUsd; // 30 decimals + 
        uint256 shortTokenAmount; // token decimals + 
        uint256 shortTokenUsd; // 30 decimals +

        int256 openInterestLong; // 30 decimals
        int256 openInterestShort; // 30 decimals
        
        int256 pnlLong; // 30 decimals + 
        int256 pnlShort; // 30 decimals + 
        int256 netPnl; // 30 decimals + 
        
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

    // WARNING: ARBITRUM ADDRESSES!
    Oracle public constant ORACLE = Oracle(0xa11B501c2dd83Acd29F6727570f2502FAaa617F2);
    DataStore public constant DATA_STORE = DataStore(0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8);
    Reader public constant READER = Reader(0xdA5A70c885187DaA71E7553ca9F728464af8d2ad);

    function getMarketPoolValueInfo(address marketID) public view returns (MarketPoolValueInfo.Props memory) {
        Market.Props memory marketProps = getMarketProps(marketID);
        MarketUtils.MarketPrices memory marketPrices = MarketUtils.getMarketPrices(address(ORACLE), marketProps);
        return READER.getMarketTokenPrice(
            dataStore,
            marketProps,
            marketPrices.indexTokenPrice,
            marketPrices.longTokenPrice,
            marketPrices.shortTokenPrice,
            Keys.MAX_PNL_FACTOR_FOR_DEPOSITS,
            true
        );
    }

    function getMarketProps(address marketID) public view returns (Market.Props memory) {
        return READER.getMarket(dataStore, marketID);
    }

    // ex: 0x47c031236e19d024b42f8AE6780E44A573170703
    function getMarketData(address marketID) external view returns (MarketDataState memory result) {
        Market.Props memory marketProps = getMarketProps(marketID);
        result.marketToken = marketProps.marketToken;
        result.indexToken = marketProps.indexToken;
        result.longToken = marketProps.longToken;
        result.shortToken = marketProps.shortToken;
        MarketPoolValueInfo.Props memory marketPoolValueInfo = getMarketPoolValueInfo(marketID);
        result.poolValue = marketPoolValueInfo.poolValue;
        result.longPnl = marketPoolValueInfo.longPnl;
        result.shortPnl = marketPoolValueInfo.shortPnl;
        result.netPnl = marketPoolValueInfo.netPnl;
        result.longTokenAmount = marketPoolValueInfo.longTokenAmount;
        result.shortTokenAmount = marketPoolValueInfo.shortTokenAmount;
        result.longTokenUsd = marketPoolValueInfo.longTokenUsd;
        result.shortTokenUsd = marketPoolValueInfo.shortTokenUsd;
    }
}
