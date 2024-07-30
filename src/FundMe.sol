// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
contract FundMe {

    using PriceConverter for uint256;

    uint256 constant public MINIMUM_ALLOWED_VALUE = 5e18;
    address immutable  PRICE_FEED_ADDRESS;
    address payable immutable  i_owner; 

    address[] private s_funders;
    mapping(address funder => uint256 amount) private s_addressToAmountFunded;

    constructor(address  _priceFeedAddress) {
        PRICE_FEED_ADDRESS = _priceFeedAddress;
        i_owner = payable(msg.sender);
    }

    function fund() public payable {
        uint256 receivedValueInUSD = msg.value.getConversionRate(PRICE_FEED_ADDRESS);
        require(receivedValueInUSD >= MINIMUM_ALLOWED_VALUE, "You didn't send enough ether");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value; 
    }

    function cheaperWithdraw() public {
        uint256 fundersLength = s_funders.length;
        for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    function withdraw() public {
        require(msg.sender == i_owner, "You are not the owner of the contract");
        uint256 fundersLength = s_funders.length;
        for(uint256 index; index < fundersLength; index++){
            address currentAddress = s_funders[index];
            s_addressToAmountFunded[currentAddress] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        require(callSuccess == true, "Sending ether to owner failed");
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

    function getPriceFeedVersion() external view returns(uint256) {
        return AggregatorV3Interface(PRICE_FEED_ADDRESS).version();
    }

    function getAddressToAmountFunded(address _address) external view returns(uint256) {
        return s_addressToAmountFunded[_address];
    }

    function getAddressAtIndex(uint256 _index) external view returns(address) {
        return s_funders[_index];
    }

    function getFunder(uint256 _index) external view returns(address) {
        return s_funders[_index];
    }

    receive() external payable  {
        fund();
    }

    fallback() external payable { 
        fund();
    }
}