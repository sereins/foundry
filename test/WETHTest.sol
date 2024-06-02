// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";
import {WETH} from "../src/WETH.sol";

contract WETHTest is Test {
    WETH weth;

    function setUp() public {
        weth = new WETH();
    }

    function testDeposit() public {
        address depositAccount = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        uint256 balance = depositAccount.balance;
        vm.prank(depositAccount);
        weth.deposit{value: 10 wei}();

        // 代币的发行量增加量
        uint256 total = weth.totalSupply();
        console2.log("token totalSupply:%s", total);
        // assertEq(total, 10);

        // 账户的余额减少
        console2.log("before: %s", depositAccount.balance);
        console2.log("after: %s", balance);

        // 账户拥有了 token weth
        console2.log("account's balance:%s", weth.balanceOf(depositAccount));

        // 合约账户用户余额
        console2.log("contract account balance:%s", address(weth).balance);
        assertEq(10, address(weth).balance);
    }

    function testWithdrawal() public {
        address depositAccount = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        uint256 balance = depositAccount.balance;

        // 存钱
        vm.prank(depositAccount);
        weth.deposit{value: 10 wei}();

        // 取钱
        vm.prank(depositAccount);
        weth.withdraw(10);

        console2.log("after balance:%s", balance);
        console2.log("token total supply:%s", weth.totalSupply());
    }
}
