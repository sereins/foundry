// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC721, IERC721Metadata, IERC165} from "forge-std/interfaces/IERC721.sol";
import {IERC721Receiver} from "forge-std/interfaces/IERC721Receiver.sol";
import "../lib/String.sol";
import "../lib/Address.sol";

contract MyERC721 is IERC721, IERC721Metadata {
    // token
    string public override name;
    string public override symbol;

    // tokenId 到owner 地址的映射
    mapping(uint => address) private owners;
    // 地址 到拥有代币数量的映射
    mapping(address => uint) private balance;
    // 授权的映射
    mapping(uint => address) private tokenApprovals;

    //  owner地址。到operator地址 的批量授权映射
    mapping(address => mapping(address => bool)) private operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // 实现165接口，供其他调用者检查 是否是721代币
    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // 代币数量
    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner == zero address");
        return balance[owner];
    }

    // 查询代币的所有者
    function ownerOf(uint tokenId) public view returns (address owner) {
        owner = owners[tokenId];
        require(owner != address(0), "token does'nt exist");
    }

    // 查询代币是否授权给了operator
    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        return operatorApprovals[owner][operator];
    }

    // 将代币全部授权给operator
    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // tokenId 的授权地址
    function getApproved(
        uint tokenId
    ) external view override returns (address) {
        require(owners[tokenId] != address(0), "token doesn't exist");
        return tokenApprovals[tokenId];
    }

    // approval
    function _approve(address owner, address to, uint tokenId) private {
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // tokenId 授权 给 to
    function approve(address to, uint tokenId) external payable override {
        address owner = owners[tokenId];
        require(
            msg.sender == owner || operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
            tokenApprovals[tokenId] == spender ||
            operatorApprovals[owner][spender]);
    }

    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        balance[from] -= 1;
        balance[to] += 1;
        owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external payable override {
        address owner = ownerOf(tokenId);

        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );

        _transfer(owner, from, to, tokenId);
    }

    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "not ERC721Receiver"
        );
    }

    /**
     * 实现IERC721的safeTransferFrom，安全转账，调用了_safeTransfer函数。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public payable override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    // safeTransferFrom重载函数
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external payable override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(owners[tokenId] == address(0), "token already minted");

        balance[to] += 1;
        owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁函数，通过调整_balances和_owners变量来销毁tokenId，同时释放Transfer事件。条件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        balance[owner] -= 1;
        delete owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    // _checkOnERC721Received：函数，用于在 to 为合约的时候调用IERC721Receiver-onERC721Received, 以防 tokenId 被不小心转入黑洞。
    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (Address.isContract(to)) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    /**
     * 实现IERC721Metadata的tokenURI函数，查询metadata。
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, String.toString(tokenId)))
                : "";
    }

    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}
