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
        StakeData memory senderLockedTokens = lockedTokens[msg.sender];
        require(
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount)
        );
        if(senderLockedTokens.amount > 0){getReward();}
        senderLockedTokens = StakeData(senderLockedTokens.amount + amount, block.timestamp);
    }

    function getReward() public {
        StakeData memory senderStake = lockedTokens[msg.sender];
        uint256 reward = (senderStake.amount *
            (block.timestamp - senderStake.date)) / stakingSecAmount;

        Linux(tokenAddress).allowedMint(msg.sender, reward);
    }

    function retrieve() public {
        address sender = msg.sender;
        IERC20 tokenContract = IERC20(tokenAddress);
        uint senderStakedTokens = lockedTokens[sender].amount;
        require(
            tokenContract.transfer(
                sender,
                senderStakedTokens
            )
        );
        lockedTokens[sender] = StakeData(0, 0);
    }

    function exit() public {
        getReward();
        retrieve();
    }
}
