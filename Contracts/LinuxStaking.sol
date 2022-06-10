pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './Linux.sol';

contract LinuxStaking is Ownable {
    address tokenAddress;

    uint256 stakingSecAmount = 1;

    struct StakeData {
        uint256 amount;
        uint256 date;
    }

    mapping(address => StakeData) lockedTokens;

    constructor(address newTokenAddress) {
        tokenAddress = newTokenAddress;
    }

    function setStakingMinuteAmount(uint256 secondsAmount) public onlyOwner {
        stakingSecAmount = secondsAmount;
    }

    function deposit(uint256 amount) public {
        require(
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount)
        );
        lockedTokens[msg.sender] = StakeData(amount, block.timestamp);
    }

    function getReward() public {
        StakeData memory senderStake = lockedTokens[msg.sender];
        uint256 reward = (senderStake.amount *
            (block.timestamp - senderStake.date)) / stakingSecAmount;

        Linux(tokenAddress).allowedMint(msg.sender, reward);
    }

    function retrieve() public {
        address sender = msg.sender;
        require(
            IERC20(tokenAddress).transferFrom(
                address(this),
                sender,
                lockedTokens[sender].amount
            )
        );
        lockedTokens[sender] = StakeData(0, 0);
    }
}
