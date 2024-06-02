// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";
import {Faucet} from "../src/Faucet.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract FaucetTest is Test {
    Faucet faucet;
    MyERC20 token;

    function setUp() public {
        MyERC20 _token = new MyERC20("IB", "ID");

        token = _token;
        faucet = new Faucet(address(_token));
    }

    function testRequst() public {
        // 给自己一点币
        token.mint(1000);

        // 将币赚到水龙头合约里面
        token.transfer(address(faucet), 500);
        uint balance = token.balanceOf(address(faucet));
        console2.log("balance of contract:%s", balance);
        assertEq(500, balance);

        vm.prank(address(0));
        // 切换用户领取币
        faucet.requested();

        uint balance1 = token.balanceOf(address(faucet));
        assertEq(400, balance1);

        uint balance2 = token.balanceOf(address(0));
        assertEq(100, balance2);
    }
}
