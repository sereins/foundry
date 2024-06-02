// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {MyERC20} from "./MyERC20.sol";

contract TokenVesting {
    event ERC20Released(address indexed token, uint256);

    mapping(address => uint256) public erc20Released;

    address public immutable beneficiary;
    uint256 public immutable start;
    uint256 public immutable duration;

    constructor(address _beneficiary, uint256 durationSecond) {
        beneficiary = _beneficiary;
        start = block.timestamp;
        duration = durationSecond;
    }

    function release(address token) public {
        uint256 release1 = vestedAmount(token, uint256(block.timestamp)) -
            erc20Released[token];
        erc20Released[token] += release1;

        emit ERC20Released(token, release1);
        MyERC20(token).transfer(beneficiary, release1);
    }

    function vestedAmount(
        address token,
        uint256 timestamp
    ) public view returns (uint256) {
        // 总共多少币
        uint256 totalAllocation = MyERC20(token).balanceOf(address(this)) +
            erc20Released[token];

        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}
