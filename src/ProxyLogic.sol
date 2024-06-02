// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ProxyLogic {
    // 与Proxy 保持一致，防止插槽冲突
    address public implemetation;

    uint public x = 99;

    event CallSuccess();

    function increment() external returns (uint) {
        emit CallSuccess();
        return x + 1;
    }
}
