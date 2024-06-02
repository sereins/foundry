// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import "../src/TokenVesting.sol";
import "../src/MyERC20.sol";

contract TokenVestingTest is Test {
    TokenVesting vest;
    MyERC20 erc20;

    // 收益的地址
    address beneficary = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        erc20 = new MyERC20("Tb", "Tb");
        // 铸币
        erc20.mint(1000);

        // 一个小时后进行释放
        vest = new TokenVesting(beneficary, 3600);

        // 将代币转入到线性释放合约中
        erc20.transfer(address(vest), 100);
    }

    function testReleased() public {
        vest.release(address(erc20));

        uint256 balance = erc20.balanceOf(beneficary);
        console2.log("beneficary account balance = %s", balance);

        vm.warp(block.timestamp + 1800);
        vest.release(address(erc20));
        uint256 balance1 = erc20.balanceOf(beneficary);
        console2.log("after 1800 sec account balance = %s", balance1);

        vm.warp(block.timestamp + 3600);
        vest.release(address(erc20));
        uint256 balance2 = erc20.balanceOf(beneficary);
        console2.log("after 3600 sec account balance = %s", balance2);
    }
}
