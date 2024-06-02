// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract MyERC20Test is Test {
    MyERC20 erc20;

    function setUp() public {
        erc20 = new MyERC20("JB", "JB");
    }

    // 测试币的信息
    function testCoinInfo() public view {
        string memory name = erc20.name();
        string memory symbol = erc20.symbol();

        assertEq(name, "JB");
        assertEq(symbol, "JB");
    }

    function testMint() public {
        erc20.mint(200);
        uint total = erc20.totalSupply();

        // 总的币
        console2.log(total);
        assertEq(200, total);

        uint balance = erc20.balanceOf(address(this));
        console2.log(balance);
        assertEq(200, balance);
    }
}
