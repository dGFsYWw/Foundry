// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Moving Chainlink import into a library
//import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    // ??
    using PriceConverter for uint256;

    uint256 public minUSD = 5e18; // Minimum value acceptable in USD
    
    // Moving dataFeed into a library
    //AggregatorV3Interface public dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Declare dataFeed variable at the contract level

    // Create an array for keeping track of who's sending funds
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    // Creating a constructor
    address public owner;
    constructor() {
        owner = msg.sender; // Making the contract deployer the owner of the contract; the only one who can w/draw
    }

    // Function syntax
    //function function_name(parameter_list) scope returns(return_type) {
       // block of code
    //}

    /* Moved getChainlinkPrice() and getConverstionRate() into a library
    // Get the price of ETH/USD from Chainlink
    function getChainlinkPrice() public view returns (uint256) {
        (,int answer,,,) = dataFeed.latestRoundData();
        return uint256(answer* 1e10); // Covert the price into Wei and convert from int to uint256
        // There are NO DECIMALS in Solidity -- need to work w/ whole #s
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        // Function syntax
        //function function_name(parameter_list) scope returns(return_type) {
        // block of code
        //}
        // ethAmount is a parameter defined alongwith the function
        uint256 ethPrice = getChainlinkPrice(); // Get price using getChainlinkPrice()
        uint256 ethAmountInUSD = (ethPrice * ethAmount)/1e18;
        return ethAmountInUSD;
    }
    */

    function fund() public payable {
        // Function must be *payable* to recieve value
        // Allow users to send $ to the contract but must be >= $5
        //require(msg.value > 1e18, "Not enough ETH baby!"); // msg.value returns value in Wei; 1e18 Wei = 1 Eth
        require(msg.value.getConversionRate() >= minUSD, "Not enough ETH baby!");
        funders.push(msg.sender);
        //msg.sender is a global variable used to track who called the contract (address of EOA or another contract)
        addressToAmountFunded[msg.sender] += msg.value;
        // The line above adds any additional funding from the same address (to keep track to cumulitive funding)
    }

    function withdraw() public onlyOwner { // onlyOwner modifier gets executed first (i.e. only contract owner gets to run this function
        // step 0: restrict this function to the owner only
        // step 1: reset values in our mapping table to 0
        // step 2: reset the addresses in our mapping table by creating a new array
        // step 3: w/ draw the money from the contract (by owner only)
        // For loop syntax: for(starting index, ending index, step amount)
        
        // step 0
        // require(msg.sender == owner, "Must be contract owner to w/draw, dude!"); // Using modifiers instead

        // step 1
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            // Above we created a counter which starts at 0 and goes up by 1 until < length of the array
            address funder = funders[funderIndex]; // Address of index 0, 1, ... etc.
            addressToAmountFunded[funder] = 0; // 'Reset' amount for address retrieved in the previous step to 0
        }

        // step 2
        funders = new address[](0);

        // step 3
            // we can transfer, send, or call
            //payable(msg.sender).transfer((address(this).balance));
            // Need to make the msg.sender address payable
            //call is the recommended way to send tokens on Ethereum (lower-level function; maybe harder to grasp at 1st)
            //call doesn't have a prerequisite amount of gas and doesn't throw an error if it fails; it returns a bool (T/F)
            (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can w/draw, DUDE!");
        _;
    }

}