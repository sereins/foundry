// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        owners[1] = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        owners[2] = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

        wallet = new MultiSigWallet(owners, 2);
    }

    function testMulti() public {
        // 向钱包中转钱
        payable(address(wallet)).transfer(1 ether);
        uint256 z = address(wallet).balance;

        // 打包交易信息
        bytes32 txInfo = wallet.encodeTransactionData(
            0x90F79bf6EB2c4f870365E785982E1f101E93b906,
            1 ether,
            "",
            0,
            1
        );

        bytes
            memory sign1 = "0x227ad58eef653b9de5060e7e3803a6ef8211b7836bc112c8f3ad36f4ab01d243573e0b66dae81127df3e1f6ea8ce0466f5db5d63af0de06ed16aa661cfc6c0101b596c48d55967ef171ade02b1c9e276ecf333ccd8dcfef7f860244fb7df56731b5866d90f7900573a2650dc1def3946f4c845996f53de5ca5d93f451ed76d3ec21c";
        console2.log("after transfer account = %s", z);
        console2.logBytes32(txInfo);

        // bytes memory signature = sign1.concat(sign2);
        wallet.execTransaction(
            0x90F79bf6EB2c4f870365E785982E1f101E93b906,
            1 ether,
            "",
            sign1
        );
    }
}
