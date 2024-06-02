// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";
import {ArrayStruct} from "../src/ArrayStruct.sol";

contract ArrayStructTest is Test {
    ArrayStruct array;

    function setUp() public {
        array = new ArrayStruct();
    }

    function testInitArray() public view {
        uint[] memory _array = array.initArray();
        uint[] memory _local = new uint[](3);
        _local[0] = 1;
        _local[1] = 2;
        _local[2] = 3;

        assertEq(_array, _local);
    }

    function testArrayPush() public {
        uint[] memory _array = array.arrayPush();

        assertEq(1, _array[0]);
        assertEq(2, _array[1]);
        assertEq(3, _array[2]);
    }
}
