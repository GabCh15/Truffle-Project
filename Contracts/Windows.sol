pragma solidity >=0.4.22 <0.9.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Windows is ERC721Enumerable, Ownable {
    uint256 uniqueIdCounter = 0;

    uint256 tokenPrice = 10;

    uint256 tokenPriceRebate = 1;

    bool isMintEnabled = true;

    address public immutable paymentToken;

    event WindowsTransfer(address from, uint256 tokensPaid, uint256 tokenAmout);

    modifier mintEnabled(){
        require(isMintEnabled, 'Mint is no enabled at this moment!');
        _;
    }

    constructor(address tokenAddress) public ERC721('Windows', 'WND') {
        paymentToken = tokenAddress;
    }

    function setTokenPrice(uint256 newTokenPrice) public onlyOwner {
        tokenPrice = newTokenPrice;
    }

    function setTokenPriceRebate(uint256 newTokenPriceRebate) public onlyOwner {
        tokenPriceRebate = newTokenPriceRebate;
    }

    function setIsMintEnabled(bool newMintLocked) public onlyOwner {
        isMintEnabled = newMintLocked;
    }

    function _windowsMint(address addresToMint) internal {
        _mint(addresToMint, uniqueIdCounter);
        uniqueIdCounter++;
    }

    function mintMultipleTokens(uint256 amount) public mintEnabled{
        uint256 price = tokenPrice * amount;
        if (amount > 1) {
            price -= tokenPriceRebate * amount;
            emit WindowsTransfer(msg.sender, price, amount);
        }

        require(
            IERC20(paymentToken).transferFrom(msg.sender, owner(), price),
            'Transfer failed'
        );
        for (uint256 i = 0; i < amount; i++) {
            _windowsMint(msg.sender);
        }
    }

    function mintToken() public  mintEnabled{
        require(
            IERC20(paymentToken).transferFrom(msg.sender, owner(), tokenPrice),
            'Transfer failed'
        );
        _windowsMint(msg.sender);
    }
}
