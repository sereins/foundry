// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {SignatureNFT} from "../src/Singature.sol";

contract SignatureTest is Test {
    SignatureNFT token;

    function setUp() public {
        token = new SignatureNFT("132", "da", address(0));
    }

    function testH() public {}
}
