pragma solidity ^0.5.8;

contract StakingStorage {
    address public underlying = address(0xf583fF9Ec0060e2810d5a07Af6c4b252C4Da6c01);
    address payable public freed = address(0x90a1fE91e0Dfc467a64ACCA393b94EA062D456FF);

    uint256 public startTime;
    uint256 public finishTime;
    uint8 public constant decimals = 8;
    uint256 public totalRewards;

    mapping(address => uint256) public accountPaid;
    mapping (address => mapping (uint32 => StakingCheckPoint)) public stakingCheckpoints;
    mapping (address => uint32) public numStakingCheckpoints;

    struct StakingCheckPoint {
        uint32 fromBlock;
        uint256 balance;
    }
}