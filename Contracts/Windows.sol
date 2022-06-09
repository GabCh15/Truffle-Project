pragma solidity >=0.4.22 <0.9.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Windows is ERC721Enumerable, Ownable {
    uint256 uniqueIdCounter = 0;

    uint256 tokenPrice = 10;

    address public immutable paymentToken;

    constructor(address tokenAddress) public ERC721('Windows', 'WND') {
        paymentToken = tokenAddress;
    }

    function setTokenPrice(uint256 newTokenPrice) public onlyOwner {
        tokenPrice = newTokenPrice;
    }

    function mintMultipleTokens(uint256 amount) public {
        require(IERC20(paymentToken).approve(
                msg.sender,
                tokenPrice * amount
            ),
            'Approval failed'
        ) ;
        
        require(
             IERC20(paymentToken).transferFrom(
                msg.sender,
                owner(),
                tokenPrice * amount
            ),
            'Transfer failed'
        );
        for(uint i = 0; i < amount; i++) _mint(msg.sender, uniqueIdCounter);
    }

    function mintToken() public {
        require(
            IERC20(paymentToken).transferFrom(msg.sender, owner(), tokenPrice),
            'Transfer failed'
        );
        _mint(msg.sender, uniqueIdCounter);
        uniqueIdCounter++;
    }
}
