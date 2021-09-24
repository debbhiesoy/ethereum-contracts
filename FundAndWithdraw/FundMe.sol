// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    
    //Create constructor for the owner's amount to be reset to "0"
    constructor() public {
        owner = msg.sender;
    }
    
    //Method which allows any one to fund with minimumUSD set which is 50
    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        //How much to fund
        addressToAmountFunded[msg.sender] += msg.value;
        //Who is funding us
        funders.push(msg.sender);
    }
    
    //Get version of the aggregrator v3 interface
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    //Get price of ethereum in USD with 18 decimals instead of 8
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
         return uint256(answer * 10000000000);
    }
    
    //Check conversion if funding is sending the right amount
    // 1000000000
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
    
    //Using modified which checks the if the owner's address
    //Modifier = is used to change the behavior of the behaviour of a function
    //in a declarative way.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    //Withdraw the amount and reset funders' amount on the current app
    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
