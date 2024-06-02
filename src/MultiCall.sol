// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract MultiCall {
    struct Call {
        address traget;
        bool allowFailure;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    function multiCall(
        Call[] calldata calls
    ) public returns (Result[] memory returnData) {
        uint256 length = calls.length;
        returnData = new Result[](length);
        Call calldata calli;

        for (uint256 i = 0; i < length; i++) {
            Result memory result = returnData[i];

            calli = calls[i];
            (result.success, result.returnData) = calli.traget.call(
                calli.callData
            );
            if (!(calli.allowFailure || result.success)) {
                revert("Multicall: call failed");
            }
        }
    }
}
