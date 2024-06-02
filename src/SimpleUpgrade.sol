// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract SimpleUpgrade {
    address public implemetation;
    address public admin;
    string public words;

    receive() external payable {}

    fallback() external payable {
        (bool success, bytes memory adata) = implemetation.delegatecall(
            msg.data
        );
    }

    constructor(address _implemetation) {
        admin = msg.sender;
        implemetation = _implemetation;
    }

    function upgrate(address newImplemetation) external {
        require(msg.sender == admin, "not admin");
        implemetation = newImplemetation;
    }
}

contract Logic1 {
    address public implemetation;
    address public admin;
    string public words;

    function foo() public {
        words = "old";
    }
}

contract Logic2 {
    address public implemetation;
    address public admin;
    string public words;

    function foo() public {
        words = "new";
    }
}
