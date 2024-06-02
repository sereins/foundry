// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {MyERC721} from "./MyERC721.sol";

contract MyERC731Ape is MyERC721 {
    uint public MAX_APES = 10000;

    constructor(
        string memory _name,
        string memory _symbol
    ) MyERC721(_name, _symbol) {}

    function mint(address _to, uint256 _tokenId) public {
        require(_tokenId >= 0 && _tokenId < MAX_APES, "tokenId out of range");
        _mint(_to, _tokenId);
    }
}
