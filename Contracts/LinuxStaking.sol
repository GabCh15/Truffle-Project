pragma solidity 0.8.10;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './Linux.sol';

contract LinuxStaking is Ownable {
    //Stores the ERC20 contract's address to used to pay
    address tokenAddress;

    //Stores the amount of seconds in which one token will be given for each staked token
    uint256 stakingSecAmount = 1;

    //Stores the stake amount and deposit date
    struct StakeData {
        uint256 amount;
        uint256 date;
    }

    //Stores the stake data for address
    mapping(address => StakeData) lockedTokens;

    modifier hasLockedTokens() {
        require(
            lockedTokens[msg.sender].amount != 0,
            'Sender has not locked tokens'
        );
        _;
    }

    /**@dev Constructs staking contraft and defines the
     *      token contract's address used to stake
     */
    constructor(address newTokenAddress) {
        tokenAddress = newTokenAddress;
    }

    /**@dev Sets a given staking reward seconds amount
     *
     * Calling conditions:
     *
     * - Only contract's owner can call this function
     */
    function setStakingSecondAmount(uint256 secondsAmount) public onlyOwner {
        stakingSecAmount = secondsAmount;
    }

    /**@dev Adds a given amount of tokens to the sender address
     *
     * Calling conditions:
     *
     * - The address of this contract needs to be allowed
     *   to transfer from sender the given amount
     * - Given amount has to be transferred to the address
     *   of this contract
     */
    function deposit(uint256 amount) public {
        StakeData memory senderLockedTokens = lockedTokens[msg.sender];
        require(
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount)
        );
        if (senderLockedTokens.amount > 0) {
            getReward();
        }
        senderLockedTokens = StakeData(
            senderLockedTokens.amount + amount,
            block.timestamp
        );
    }

    /**@dev Mints the reward amount of tokens to the sender
     *
     * Calling conditions:
     *
     * - Sender has to have locked tokens
     */
    function getReward() public hasLockedTokens {
        address sender = msg.sender;
        StakeData memory senderStake = lockedTokens[sender];
        uint256 reward = (senderStake.amount *
            (block.timestamp - senderStake.date)) / stakingSecAmount;
        Linux(tokenAddress).allowedMint(msg.sender, reward);
        lockedTokens[sender] = StakeData(senderStake.amount, block.timestamp);
    }

    /**@dev Retrieves back the locked tokens of sender
     *
     * Calling conditions:
     *
     * - Sender has to have locked tokens
     */
    function retrieve() public hasLockedTokens {
        address sender = msg.sender;
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 senderStakedTokens = lockedTokens[sender].amount;
        require(tokenContract.transfer(sender, senderStakedTokens));
        lockedTokens[sender] = StakeData(0, 0);
    }

    /**@dev Retrieves back the locked tokens
     *      of sender and gets rewards
     *
     * Calling conditions:
     *
     * - Sender has to have locked tokens
     */
    function exit() public {
        getReward();
        retrieve();
    }
}
