// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Libraries are like contracts, but can't have any state variables and functions must be 'internal'

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    // Get the price of ETH/USD from Chainlink
    function getChainlinkPrice() internal view returns (uint256) {
        // Sepolia ETH / USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer* 1e10); // Covert the price into Wei and convert from int to uint256
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        // Function syntax
        //function function_name(parameter_list) scope returns(return_type) {
        // block of code
        //}
        // ethAmount is a parameter defined alongwith the function
        uint256 ethPrice = getChainlinkPrice(); // Get price using getChainlinkPrice()
        uint256 ethAmountInUSD = (ethPrice * ethAmount)/1e18;
        return ethAmountInUSD;
    }


}