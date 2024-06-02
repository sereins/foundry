// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";

contract AbiTest is Test {
    function setUp() public {}

    function testEncode() public pure {
        uint256 x = 12;
        uint[2] memory array = [uint(2), 3];

        bytes memory data = abi.encode(x, array);

        console2.logBytes(data);
        console2.log(data.length);
    }
}
