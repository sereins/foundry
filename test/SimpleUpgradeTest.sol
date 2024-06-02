// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {SimpleUpgrade, Logic1, Logic2} from "../src/SimpleUpgrade.sol";

contract SimpleUpgradeTest is Test {
    SimpleUpgrade upgrade;

    function setUp() public {
        Logic1 logic1 = new Logic1();
        upgrade = new SimpleUpgrade(address(logic1));
    }

    function testOld() public {
        address(upgrade).call(abi.encodeWithSignature("foo()"));
        (, bytes memory data) = address(upgrade).call(
            abi.encodeWithSignature("words()")
        );

        string memory rs = abi.decode(data, (string));
        console2.logString(rs);
    }

    function testNew() public {
        Logic2 logic = new Logic2();
        upgrade.upgrate(address(logic));

        address(upgrade).call(abi.encodeWithSignature("foo()"));
        (, bytes memory data) = address(upgrade).call(
            abi.encodeWithSignature("words()")
        );

        string memory rs = abi.decode(data, (string));
        console2.logString(rs);
    }
}
