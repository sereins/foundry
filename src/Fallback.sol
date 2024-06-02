// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Fallback {
    event Received(address sender, uint256 value);
    event Fallbacked(address sender, uint256 value);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Fallbacked(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256 _balance) {
        _balance = address(this).balance;
    }
}
