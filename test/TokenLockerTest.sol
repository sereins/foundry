// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import "../src/MyERC20.sol";
import "../src/TokenLocker.sol";

contract TokenLockerTest is Test {
    TokenLocker locker;
    MyERC20 erc20;

    // 收益的地址
    address beneficary = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        erc20 = new MyERC20("Tb", "Tb");
        // 铸币
        erc20.mint(1000);

        // 一个小时后进行释放
        locker = new TokenLocker(erc20, beneficary, 3600);

        // 代币转移到锁定合约中
        erc20.transfer(address(locker), 100);
    }

    function testRelease() public {
        uint256 balance = erc20.balanceOf(beneficary);
        console2.log("beneficary account balance = %s", balance);

        vm.warp(block.timestamp + 3601);
        locker.release();
        uint256 balance1 = erc20.balanceOf(beneficary);
        console2.log("after 3600 sec account balance = %s", balance1);
    }
}
