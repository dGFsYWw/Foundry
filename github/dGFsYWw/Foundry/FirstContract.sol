// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HelloWorld {

    string public message = "Hello world!";

    constructor (string memory initialMessage) {
        message = initialMessage;
    }    

    function updateMessage(string memory newMessage) external {
        message = newMessage;
    }

}
