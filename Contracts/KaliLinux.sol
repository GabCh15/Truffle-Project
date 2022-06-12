pragma solidity 0.8.10;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './WindowsXP.sol';

contract KaliLinux is ERC20, Ownable {
    //Stores whether the address key has already minted or not
    mapping(address => bool) alreadyMinted;

    //Stores the staking contract address
    address stakingAddress;

    //Checks whether the sender address is the allowed staking address or hasn't minted yet
    modifier onlyAllowed() {
        address sender = msg.sender;
        require(
            alreadyMinted[sender] == false || sender == stakingAddress,
            'Sender is not allowed to mint!'
        );
        _;
    }

    /** @dev Constructs and define an ERC20 token, name and symbol
     *
     */
    constructor() public ERC20('KaliLinux', 'KLL') {}

    /** @dev Sets staking contract's address
     *
     * Calling conditions:
     *
     * - Only the contract's owner can call this function
     */
    function setStakingAddress(address stakingContractAddress)
        public
        onlyOwner
    {
        stakingAddress = stakingContractAddress;
    }

    /** @dev Mints a given amount of tokens to a given address
     *
     * Calling conditions:
     *
     * - Only callable once by any account address
     * - Staking contract address can call it any amount of time
     */
    function allowedMint(address addressToMint, uint256 amount)
        public
        onlyAllowed
    {
        _mint(addressToMint, amount);
    }

    /** @dev Withdraws a given amount of tokens
     *       to sender
     *
     * Calling conditions:
     *
     * - Sender balance has to be equal or major to withdraw amount
     */
    function withdrawLnx(uint256 amount) public {
        require(
            balanceOf(msg.sender) >= amount,
            "User balance isn't more or equal to that amount of Lnx"
        );
        _burn(msg.sender, amount);
        msg.sender.call{value: amount}('');
    }

    /** @dev Mints the paid amount of ETH to sender
     *
     * Calling conditions:
     *
     * - Sender can only call this function once
     */
    function firstMint() external payable {
        address sender = msg.sender;
        allowedMint(sender, msg.value);
        alreadyMinted[sender] = true;
    }

    function approveAndCall(
        address contractAddress,
        uint allowanceAmount,
        bytes memory data
    ) external {
        approve(contractAddress, allowanceAmount);
        contractAddress.call(data);
    }
}
