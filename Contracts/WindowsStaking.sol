pragma solidity >=0.4.22 <0.9.0;

import './Windows.sol';

contract Staking is Windows {
    mapping(address => mapping(uint256 => uint256)) lockedTokens;

    mapping(address => uint256[]) lockedTokenIds;

    constructor(address tokenAddress) Windows(tokenAddress) {}

    modifier tokenIsLocked(uint256 tokenId) {
        require(lockedTokens[msg.sender][tokenId] != 0, 'Token is not locked!');
        _;
    }

    //Deposit a token by ID
    function deposit(uint256 tokenId) public {
        address senderAddress = msg.sender;
        require(
            ownerOf(tokenId) == senderAddress,
            'Token is not owned by sender!'
        );
        lockedTokens[senderAddress][tokenId] = block.timestamp;
        lockedTokenIds[senderAddress].push(tokenId);
        _transfer(senderAddress, address(this), tokenId);
    }

    //Retrieve a token by ID
    function retrieve(uint256 tokenId) public tokenIsLocked(tokenId) {
        address senderAddress = msg.sender;
        lockedTokens[senderAddress][tokenId] = 0;
        removeByValue(tokenId, lockedTokenIds[senderAddress]);
        _transfer(address(this), senderAddress, tokenId);
        getRewards(tokenId);
    }

    //Get reward by token ID
    function getRewards(uint256 tokenId) internal {
        address senderAddress = msg.sender;
        uint256 reward = (block.timestamp -
            lockedTokens[senderAddress][tokenId]) / 60;
        msg.sender.call{value: reward}('');
    }

    function depositAll() public {
        address senderAddress = msg.sender;
        uint senderBalance = balanceOf(senderAddress);
        for (uint256 i = 0; i < senderBalance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(senderAddress, i);

            if (lockedTokens[msg.sender][tokenId] == 0) deposit(tokenId);
        }
    }

    function retrieveAll() public {
        address senderAddress = msg.sender;
        for (uint256 i = 0; i < lockedTokenIds[senderAddress].length; i++) {
            uint256 tokenId = lockedTokenIds[senderAddress][i];
            if (lockedTokens[msg.sender][tokenId] != 0) {
                retrieve(tokenId);
                getRewards(tokenId);
            }
        }
    }

    function removeByValue(uint256 value, uint256[] memory values) public {
        uint256 i = find(value, values);
        delete values[i];
    }

    function find(uint256 value, uint256[] memory values)
        public
        returns (uint256)
    {
        uint256 i = 0;
        while (values[i] != value) {
            i++;
        }
        return i;
    }
}