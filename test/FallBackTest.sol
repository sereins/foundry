// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback fall;

    function setUp() public {
        fall = new Fallback();
    }

    function testReceive() public payable {
        payable(address(fall)).transfer(1 wei);

        uint256 balance = fall.getBalance();
        assertEq(1, balance);
    }

    function testFallback() public payable {
        bytes memory data = abi.encodeWithSignature("dd");
        payable(address(fall)).call{value: 5}(data);

        uint256 balance = fall.getBalance();
        assertEq(5, balance);
    }
}
