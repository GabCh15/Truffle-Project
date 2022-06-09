pragma solidity >=0.4.22 <0.9.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Windows is ERC721Enumerable, Ownable {
    uint256 uniqueIdCounter = 0;

    uint256 tokenPrice = 10;

    uint256 tokenPriceRebate = 1;

    address public immutable paymentToken;

    constructor(address tokenAddress) public ERC721('Windows', 'WND') {
        paymentToken = tokenAddress;
    }

    function setTokenPrice(uint256 newTokenPrice) public onlyOwner {
        tokenPrice = newTokenPrice;
    }

    function setTokenPriceRebate(uint256 newTokenPriceRebate) public onlyOwner {
        tokenPriceRebate = tokenPriceRebate;
    }

    function mintMultipleTokens(uint256 amount) public {
        require(
            IERC20(paymentToken).transferFrom(
                msg.sender,
                owner(),
                tokenPrice * amount
            ),
            'Transfer failed'
        );
        for (uint256 i = 0; i < amount; i++) mintToken();
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
