// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";

import "../src/TheToken.sol";

contract TheERC20Test is Test {
    TheToken theToken;

    function setUp() public {
        theToken = new TheToken("The", "T");
    }

    function testMint() public {
        theToken.mint(address(this), 100);

        uint256 aa = theToken.balanceOf(address(this));
        console2.log(aa);
    }
}
