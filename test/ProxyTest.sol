// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {ProxyLogic} from "../src/ProxyLogic.sol";

contract ProxyTest is Test {
    Proxy proxy;

    function setUp() public {
        ProxyLogic logic = new ProxyLogic();
        proxy = new Proxy(address(logic));
    }

    function testCall() public {
        (, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );

        console2.logBytes(data);
    }
}
