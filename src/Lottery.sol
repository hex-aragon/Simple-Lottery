// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "forge-std/console.sol"; 

contract Lottery {
    address public owner;
    address[] public players;
    address[] public lastWinners;
    mapping(address => uint) public entryCount; 
    
    uint public constant MAX_ENTRIES = 3; // address당 최대 3번
    uint public constant WINNER_COUNT = 3; // last winner 설정 

    constructor() {
        owner = msg.sender;
    }
    
    //enter 계정별 3회 체크 
    function enter() public payable {
        require(msg.value == 0.001 ether, "Must send exactly 0.001 ether to enter");
        require(entryCount[msg.sender] < MAX_ENTRIES, "You can only enter 3 times");
        
        entryCount[msg.sender] += 1; 
        players.push(msg.sender);

        console.log("Player entered: %s", msg.sender);
        console.log("Total players: %s", players.length);
    }
    
    //chainlink vrf로 변경하려 했으나 진행 못함
    function random() private view returns(uint) {
        return uint(keccak256(abi.encode(block.timestamp, block.prevrandao, block.number, players, msg.sender)));
    }

    //승자 뽑기
    function pickWinner() public onlyOwner {
        require(players.length >= WINNER_COUNT, "Not enough players to pick winners");
        console.log("random: %d",random()); 
        
        //vrf 변경 필요 
        uint index = random() % (players.length);
        console.log("index: %s",index);

        address[] memory selectedWinners = new address[](WINNER_COUNT);
        uint balanceToDistribute = address(this).balance / WINNER_COUNT;

        for(uint i = 0; i < WINNER_COUNT; i++) {
            uint winnerIndex = (index + i) % players.length;
            selectedWinners[i] = players[winnerIndex];  
            payable(players[winnerIndex]).transfer(balanceToDistribute);
        }

        lastWinners = selectedWinners;  
        players = new address[](0) ;
    }

    function getWinners() public view returns (address[] memory) {
        return lastWinners;
    }

    
    function getPlayersLength() public view returns (uint) {
        return players.length;
    }
    
    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
}
