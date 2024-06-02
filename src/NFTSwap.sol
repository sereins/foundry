// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {IERC721Receiver} from "forge-std/interfaces/IERC721Receiver.sol";

contract NFTSwap is IERC721Receiver {
    event Received(address operator, address from, uint tokenId, bytes data);

    // 关于交易的订单
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );

    // 购买
    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );

    // 撤销订单
    event Revoke(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );

    // 修改订单价格
    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice
    );

    // 订单的结构
    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) public nftList;

    receive() external payable {}

    fallback() external payable {}

    // 挂单
    function list(address _nftAddr, uint256 _tokenId, uint256 price) public {
        IERC721 _nft = IERC721(_nftAddr);

        require(_nft.getApproved(_tokenId) == address(this), "Need Approval");
        require(price >= 0);

        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = price;

        // nft 转账到合约
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        emit List(msg.sender, _nftAddr, _tokenId, price);
    }

    // 购买
    function purchase(address _nftAddress, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddress][_tokenId];
        // // 价格验证
        require(_order.price >= 0);
        require(msg.value >= _order.price, "value not enough");

        // 所有权验证
        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == address(this));

        // nft转移给 购买者
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddress][_tokenId];

        // 发出事件
        emit Purchase(msg.sender, _nftAddress, _tokenId, _order.price);
    }

    // 取消挂单
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "not owner");

        IERC721 nft = IERC721(_nftAddr);
        require(nft.ownerOf(_tokenId) == address(this));

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];

        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    // 修改价格
    function update(address _nftAddr, uint256 _tokenId, uint256 price) public {
        Order storage _order = nftList[_nftAddr][_tokenId];

        require(_order.owner == msg.sender, "not owner");
        require(price >= 0);

        IERC721 nft = IERC721(_nftAddr);
        require(nft.ownerOf(_tokenId) == address(this));

        _order.price = price;

        emit Update(msg.sender, _nftAddr, _tokenId, price);
    }

    // 是否能否接收币的函数
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit Received(operator, from, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    function getNFTOrder(
        address _nftAddr,
        uint256 _tokenId
    ) public view returns (address, uint256) {
        Order memory _order = nftList[_nftAddr][_tokenId];
        return (_order.owner, _order.price);
    }
}
