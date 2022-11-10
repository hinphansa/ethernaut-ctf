// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MagicNum {

  address public solver;

  constructor() public {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}

/*
    *** RUN TIME OPCODE ***

    60 2a	//PUSH1 0x2a (value = 42)
    60 80	//PUSH1 0x00 (offset = 80)
    52	    //MSTORE

    60 20	//PUSH1 0x20 (length 32 bytes)
    60 80	//PUSH1 0x00 (offset 80)
    f3	    //RETURN

    ___ 602a60805260206080f3 ___
*/

/*
    *** INITIALIZING OPCODE ***

    * copy runtime opcode *
    60 0a   //PUSH1 0x0a    (10 bytes)
    60 0c   //PUSH1 0x??    -> init opcode length (from copy to return) is 12 bytes so the runtime opcode gonna start at 0x0c
    60 00   //PUSH1 0x00    (destination memory index 0)
    39      //CODECOPY

    * return opcode *
    60 0a   //PUSH1 0x0a (length 10 bytes)
    60 00   //PUSH1 0x00 (offset 0)
    f3      //RETURN (return to EVM)

    ___ 600a600c600039600a6000f3 ___
*/

/****
    
    SO THE CONTRACT OPCODE GONNA BE 600a600c600039600a6000f3602a60805260206080f3

    0x600a600c600039600a6000f3604260805260206080f3
    0x600a600c600039600a6000f3604260805260206080f3
    
****/