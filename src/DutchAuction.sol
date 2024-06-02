// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTION_SIZE = 10000;
    uint256 public constant AUCTION_START_PRICE = 1 ether;
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;
    uint256 public constant AUCTION_TIME = 10 minutes;
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
            (AUCTION_TIME / AUCTION_DROP_INTERVAL);

    uint256 public auctionStartTime;
    string private _baseTokenURI;
    uint256[] private _allTokens;

    constructor() Ownable(msg.sender) ERC721("WTF DUCTION", "WTF") {
        auctionStartTime = block.timestamp;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // 拍卖函数
    function auctionMint(uint256 quantity) external payable {
        // 建立local变量 减少gas的花费
        uint256 _saleStartTime = uint256(auctionStartTime);

        require(
            _saleStartTime != 0 && block.timestamp > _saleStartTime,
            "sale has not started yet"
        );

        require(totalSupply() + quantity <= COLLECTION_SIZE, "casda");
        uint256 totalCost = getAuctionPrice() * quantity;

        require(msg.value >= totalCost);

        for (uint256 i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        // 重入攻击
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    // 获取当前的价格
    function getAuctionPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
            return AUCTION_START_PRICE;
        } else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
            return AUCTION_END_PRICE;
        } else {
            uint256 steps = (block.timestamp - auctionStartTime) /
                AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    // BaseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // BaseURI setter函数, onlyOwner
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // 提款函数，onlyOwner
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
