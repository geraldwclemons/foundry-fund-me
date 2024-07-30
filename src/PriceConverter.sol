// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // ETHUSD PRICEFEED ON SEPOLIA => 0x694AA1769357215DE4FAC081bf1f309aDC325306

    function getConversionRate(uint256 _ethValueToConvert, address _priceFeedAddress) internal view returns(uint256) {
        uint256 price = getPrice(_priceFeedAddress);
        uint256 receivedValueInUSD = _ethValueToConvert * (price * 10 ** 10);
        return receivedValueInUSD;
    }

    function getPrice(address _priceFeedAddress) internal view returns(uint256) {
        AggregatorV3Interface priceFeedContract = AggregatorV3Interface(_priceFeedAddress);
        (,int answer,,,) = priceFeedContract.latestRoundData();
        uint256 price = uint256(answer);
        return price;
    }

    
}