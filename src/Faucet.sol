// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {IERC20} from "../lib/forge-std/src/interfaces/IERC20.sol";

contract Faucet {
    uint256 public allowamount = 100;
    address public tokenContract;
    mapping(address => bool) public requestedAddress;

    event SentToken(address Receive, uint256 amount);

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }

    function requested() public {
        require(!requestedAddress[msg.sender], "");

        // 转合约对象
        IERC20 token = IERC20(tokenContract);

        uint256 balance = token.balanceOf(address(this));
        require(balance >= allowamount);

        token.transfer(msg.sender, allowamount);
        emit SentToken(msg.sender, allowamount);
    }
}
