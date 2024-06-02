// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TheToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amounts) external {
        _mint(to, amounts);
    }

    function burn(address account, uint256 amoutns) external {
        _burn(account, amoutns);
    }
}
