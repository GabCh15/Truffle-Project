pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Linux is ERC20{
    mapping(address => uint) public lockedDate;

    constructor() public ERC20("Linux", "LNX") {
    }

       function withdrawLnx(uint amount) public payable {
            require(
                balanceOf(msg.sender) >= amount, "User balance isn't more or equal to that amount of Lnx"
            );
         _burn(msg.sender,amount);
         msg.sender.call{value:amount}("");
    }

       function getRewards() public payable {
           require(
                balanceOf(msg.sender) != 0, "User balance is 0"
            );
           uint reward = balanceOf(msg.sender) * 1/8 * (block.timestamp-lockedDate[msg.sender])/60;
         msg.sender.call{value:reward}("");
    }

    receive() external payable{
     _mint(msg.sender,msg.value);
    }
}