// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Lottery.sol";
import "forge-std/console.sol"; 

contract LotteryTest is Test {
    Lottery public lottery;
    address public owner = address(this);
    address public player1 = address(0x1);
    address public player2 = address(0x2);
    address public player3 = address(0x3);
    address public player4 = address(0x4);
    address public player5 = address(0x5);
    address public player6 = address(0x6);

    function setUp() public {
        lottery = new Lottery();
    }

    //심플 테스트 
    function testEnterPlayer1() public {
        console.log("TEST %s");
        vm.deal(player1, 1 ether);
        vm.prank(player1);
        lottery.enter{value: 0.001 ether}();
        assertEq(lottery.players(0), player1);
    }

    //반복 호출 
    function testEnterPlayerModule(address player) public {
        console.log("player: %s",player);
        vm.deal(player, 1 ether);
        vm.prank(player);
        lottery.enter{value: 0.001 ether}();
        vm.roll(block.number + 1); // Advance block number
        vm.warp(block.timestamp + 1); // Advance block time
    }

function testPickWinner() public {
    // Repeatedly call the entry function for each player
    testEnterPlayerModule(player1);
    testEnterPlayerModule(player2);
    testEnterPlayerModule(player3);
    testEnterPlayerModule(player4);
    testEnterPlayerModule(player5);
    testEnterPlayerModule(player6);

    // Check if the balance of the first three players is greater than 0
    assertGt(address(player1).balance + address(player2).balance + address(player3).balance, 0);
    
    // Verify that the correct number of players have entered
    assertEq(lottery.getPlayersLength(), 6);

    // Pick winners
    lottery.pickWinner();

    // Get the winners' array
    address[] memory winners = lottery.getWinners();

    // Log each winner's address individually
    for (uint i = 0; i < winners.length; i++) {
        console.log("Winner %s: %s", i+1, winners[i]);
    }

    // Ensure that exactly 3 winners were selected
    assertEq(winners.length, 3, "There should be exactly 3 winners");

    console.log("winners length: %d", winners.length);
}


}
