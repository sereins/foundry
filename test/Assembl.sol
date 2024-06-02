// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";

contract Assembl is Test {
    function setUp() public {}

    function testAdd() public pure {
        uint256 x;

        assembly {
            x := add(2, 3)
        }

        console2.log(x);
    }
}
