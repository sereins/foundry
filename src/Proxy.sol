// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 代理合约
contract Proxy {
    address public implementation;

    constructor(address implementation_) {
        implementation = implementation_;
    }

    receive() external payable {
        _delegate();
    }

    fallback() external payable {
        _delegate();
    }

    function _delegate() internal {
        assembly {
            // 读取storage 为0的数据，也就是logic合约的地址
            let _implemetation := sload(0)

            // 将calldata 复制到内存中
            calldatacopy(0, 0, calldatasize())

            // 调用逻辑合约
            let result := delegatecall(
                gas(),
                _implemetation,
                0,
                calldatasize(),
                0,
                0
            )

            // 将returndata 复制到内存中
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
