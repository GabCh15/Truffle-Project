pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';

contract LinuxStaking is Ownable {
    address tokenAddress;

    uint256 stakingSecAmount = 1;

    constructor(address newTokenAddress) {
        tokenAddress = newTokenAddress;
    }

    function setStakingMinuteAmount(uint256 secondsAmount) public onlyOwner {
        stakingSecAmount = secondsAmount;
    }

    
}
