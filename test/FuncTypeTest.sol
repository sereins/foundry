// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FunctionType} from "../src/FunctionType.sol";

contract FuncTest is Test {
    FunctionType public funcType;

    function setUp() public {
        funcType = new FunctionType();
    }

    function test_Add() public {
        funcType.add();
        assertEq(funcType.number(), 1);
    }

    function test_view() public view {
        uint256 num = funcType.views();
        assertEq(num, 0);
    }

    function test_minusCall() public {
        funcType.minusCall();
        assertEq(1, funcType.number());
    }

    function testPay() public {
        uint256 balance = funcType.minusPay();
        assertEq(0, balance);
    }

    // function testFail_pur(uint256 _number) public view {
    //     uint256 x = funcType.pur(_number);
    //     assertEq(x, _number + 1);
    // }
}
