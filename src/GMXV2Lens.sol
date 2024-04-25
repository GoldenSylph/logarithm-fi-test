// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@gmx-io/synthetics/market/Market.sol";
import "@gmx-io/synthetics/market/MarketUtils.sol";
import "@gmx-io/synthetics/market/MarketPoolValueInfo.sol";

import "@gmx-io/synthetics/data/DataStore.sol";
import "@gmx-io/synthetics/data/Keys.sol";

import "@gmx-io/synthetics/price/Price.sol";
import "@gmx-io/synthetics/reader/Reader.sol";
import "@gmx-io/synthetics/oracle/Oracle.sol";

contract GMXV2Lens is UUPSUpgradeable {
    struct MarketDataState {
        address marketToken; // +
        address indexToken; // +
        address longToken; // +
        address shortToken; // +

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

    address public dataStore;
    Reader public reader;

    function initialize(address _dataStore, address _reader) external initializer {
        dataStore = _dataStore;
        reader = Reader(_reader);
    }

    function getMarketPoolValueInfo(address marketID, Oracle oracle, bool maximize) public view returns (MarketPoolValueInfo.Props memory) {
        Market.Props memory marketProps = getMarketProps(marketID);
        MarketUtils.MarketPrices memory marketPrices = MarketUtils.getMarketPrices(oracle, marketProps);
        bytes32 pnlFactorType;
        return reader.getMarketTokenPrice(
            dataStore,
            marketProps,
            marketPrices.indexTokenPrice,
            marketPrices.longTokenPrice,
            marketPrices.shortTokenPrice,
            pnlFactorType,
            maximize
        );
    }

    function getMarketProps(address marketID) public view returns (Market.Props memory) {
        return reader.getMarket(dataStore, marketID);
    }

    function getMarketData(address marketID) external view returns (MarketDataState memory result) {
        Market.Props memory marketProps = getMarketProps(marketID);
        result.marketToken = marketProps.marketToken;
        result.indexToken = marketProps.indexToken;
        result.longToken = marketProps.longToken;
        result.shortToken = marketProps.shortToken;


    }
}
