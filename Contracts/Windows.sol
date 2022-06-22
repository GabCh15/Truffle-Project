pragma solidity 0.8.10;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Windows is ERC721Enumerable, Ownable {
    //Stores the token price
    uint256 tokenPrice = 10;

    //Stores a rebate in token amount to discount on mint
    uint8 tokenPriceRebate = 1;

    //Stores whether minting is enabled
    bool isMintEnabled = true;

    //Stores the ERC20 contract's address used to pay
    address public immutable paymentToken;

    //Percent const to make percentage operations
    uint8 private constant PERCENT = 100;

    //Checks whether the mint is enabled
    modifier mintEnabled() {
        require(isMintEnabled, 'Mint is no enabled at this moment!');
        _;
    }

    /**@dev Contructs an ERC721 token, name, symbol
     *      and defines the token contract's address
     *      used to pay
     */
    constructor(address tokenAddress) public ERC721('Windows', 'WND') {
        paymentToken = tokenAddress;
    }

    /**@dev Sets a given token price
     *
     * Calling conditions:
     *
     * - Only contract's owner can call this function
     */
    function setTokenPrice(uint256 newTokenPrice) public onlyOwner {
        tokenPrice = newTokenPrice;
    }

    /**@dev Sets a given price rebate
     *
     * Calling conditions:
     *
     * - Only contract's owner can call this function
     */
    function setTokenPriceRebate(uint8 newTokenPriceRebate) public onlyOwner {
        tokenPriceRebate = newTokenPriceRebate;
    }

    /**@dev Sets whether this ERC721 mint is enabled
     *
     * Calling conditions:
     *
     * - Only contract's owner can call this function
     */
    function setIsMintEnabled(bool newMintLocked) public onlyOwner {
        isMintEnabled = newMintLocked;
    }

    /**@dev Mints a token to given address with unique token id
     */
    function _windowsMint(address addresToMint) internal {
        _mint(addresToMint, totalSupply());
    }

    /**@dev Calculates price to pay for given amount of tokens
     */
    function _calculatePrice(uint256 amount) internal view returns (uint256) {
        if (amount == 1) return tokenPrice;
        return (tokenPrice * amount * (PERCENT - tokenPriceRebate)) / PERCENT;
    }

    /**@notice Mints given amount of tokens to sender address
     *
     * Calling conditions:
     *
     * - Mint has to be enabled
     * - The address of this contract needs to be allowed
     *   to transfer from sender 'tokenPrice * amount' amount
     * - Tokens total price has to be transferred to the address
     *   of this contract
     */
    function mintMultipleTokens(uint256 amount) public mintEnabled {
        require(
            IERC20(paymentToken).transferFrom(
                msg.sender,
                owner(),
                _calculatePrice(amount)
            ),
            'Transfer failed'
        );

        for (uint256 i = 0; i < amount; i++) {
            _windowsMint(msg.sender);
        }
    }

    /**@notice Mints given amount of tokens to sender address}
     *
     * Calling conditions:
     *
     * - Mint has to be enabled
     * - The address of this contract needs to be allowed
     *   to transfer from sender 'tokenPrice * amount' amount
     * - Tokens price has to be transferred to the address
     *   of this contract
     */
    function mintToken() public mintEnabled {
        require(
            IERC20(paymentToken).transferFrom(msg.sender, owner(), tokenPrice),
            'Transfer failed'
        );
        _windowsMint(msg.sender);
    }
}
