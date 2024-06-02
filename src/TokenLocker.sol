// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/interfaces/IERC20.sol";

contract TokenLocker {
    event TokenLockStart(
        address indexed beneficiary,
        address indexed token,
        uint256 startTime,
        uint256 lockTime
    );

    event Release(
        address indexed beneficiary,
        address indexed token,
        uint256 releaseTime,
        uint256 amount
    );

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable lockTime;
    uint256 public immutable startTime;

    constructor(IERC20 _token, address _beneficiary, uint256 _lockTime) {
        require(_lockTime > 0, "TokenLocker:lock time should gt 0");

        beneficiary = _beneficiary;
        lockTime = _lockTime;
        startTime = block.timestamp;
        token = _token;

        emit TokenLockStart(
            _beneficiary,
            address(_token),
            startTime,
            _lockTime
        );
    }

    function release() public {
        // 判断时间
        require(
            block.timestamp >= lockTime + startTime,
            "TokenLock:current time is before release time"
        );

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no token to release");
        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }
}
