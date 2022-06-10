pragma solidity >=0.4.22 <0.9.0;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/*interface ILinux {
    function allowedMint(address addressToMint, uint256 amount) external;
}*/

contract Linux is ERC20, Ownable {
    mapping(address => bool) alreadyMinted;

    address stakingAddress;

    modifier onlyAllowed() {
        address sender = msg.sender;
        require(
            alreadyMinted[sender] == false || sender == stakingAddress,
            'Sender is not allowed to mint!'
        );
        _;
    }

    constructor() public ERC20('Linux', 'LNX') {}

    function setStakingAddress(address stakingContractAddress)
        public
        onlyOwner
    {
        stakingAddress = stakingContractAddress;
    }

    function allowedMint(address addressToMint, uint256 amount)
        public 
        onlyAllowed
    {
        _mint(addressToMint, amount);
    }

    function withdrawLnx(uint256 amount) public {
        require(
            balanceOf(msg.sender) >= amount,
            "User balance isn't more or equal to that amount of Lnx"
        );
        _burn(msg.sender, amount);
        msg.sender.call{value: amount}('');
    }

    function firstMint() external payable {
        address sender = msg.sender;
        allowedMint(sender, msg.value);
        alreadyMinted[sender] = true;
    }
}
