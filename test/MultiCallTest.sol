// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {MultiCall} from "../src/MultiCall.sol";
import {MyERC20} from "../src/MyERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MultiCallTest is Test {
    MultiCall multiCall;
    MyERC20 erc20;

    function setUp() public {
        multiCall = new MultiCall();
        erc20 = new MyERC20("TB", "TB");
    }

    function testMultiCall() public {
        address addr1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        address addr2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

        // 给账户1 发币100个
        vm.prank(addr1);
        erc20.mint(100);

        // 给账户2发币100个
        vm.prank(addr2);
        erc20.mint(50);

        // 多重调用查询结果
        bytes memory calldata1 = abi.encodeWithSignature(
            "_balanceOf(address)",
            addr1
        );
        MultiCall.Call memory call1 = MultiCall.Call(
            address(erc20),
            false,
            calldata1
        );

        bytes memory calldata2 = abi.encodeWithSignature(
            "_balanceOf(address)",
            addr2
        );
        MultiCall.Call memory call2 = MultiCall.Call(
            address(erc20),
            false,
            calldata2
        );

        MultiCall.Call[] memory data = new MultiCall.Call[](2);
        data[0] = call1;
        data[1] = call2;

        MultiCall.Result[] memory result = multiCall.multiCall(data);
        for (uint256 i = 0; i < result.length; i++) {
            MultiCall.Result memory res = result[i];
            console2.log(res.success);
            console2.log(uint256(bytesToUint(res.returnData)));
        }
    }
}
