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

    event AddressLockedTokens(uint256 lockedTokens);

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

    /**@notice Adds a given amount of tokens to the sender address
     *
     * Calling conditions:
     *
     * - The address of this contract needs to be allowed
     *   to transfer from sender the given amount
     * - Given amount has to be transferred to the address
     *   of this contract
     */
    function deposit(uint256 amount) public {
        address sender = msg.sender;
        StakeData memory senderStake = lockedTokens[sender];
        require(
            IERC20(tokenAddress).transferFrom(sender, address(this), amount)
        );
        getReward();
        lockedTokens[sender] = StakeData(senderStake.amount + amount, block.timestamp);
    }

    /**@dev Calculates the reward to mint to sender address
     */
    function _calculateReward(address sender) internal view returns (uint256) {
        StakeData memory senderStake = lockedTokens[sender];
        return
            (senderStake.amount * (block.timestamp - senderStake.date)) /
            stakingSecAmount;
    }

    /**@notice Mints the reward amount of tokens to the sender
     *
     * Calling conditions:
     *
     * - Sender has to have locked tokens
     */
    function getReward() public {
        address sender = msg.sender;
        uint256 reward = _calculateReward(sender);
        if (reward == 0) return;
        Linux(tokenAddress).allowedMint(sender, reward);
        lockedTokens[sender].date = block.timestamp;
    }

    /**@notice Retrieves back the locked tokens of sender
     *
     * Calling conditions:
     *
     * - Sender has to have locked tokens
     */
    function retrieve() public hasLockedTokens {
        address sender = msg.sender;
        uint256 senderStakedTokens = lockedTokens[sender].amount;
        require(IERC20(tokenAddress).transfer(sender, senderStakedTokens));
        lockedTokens[sender] = StakeData(0, 0);
    }

    /**@notice Retrieves back the locked tokens
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
