// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract MyERC20 is IERC20 {
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    // 代币的总供给
    uint256 public override totalSupply;

    string public override name;
    string public override symbol;
    uint8 public override decimals = 18;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // 代币转账
    function transfer(
        address recipient,
        uint amount
    ) public override returns (bool) {
        // 调用者是否具有足够多的代币
        require(balanceOf[msg.sender] >= amount);

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 代币授权
    function approve(
        address spender,
        uint amount
    ) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 代币授权转账逻辑
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 铸币
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply = totalSupply + amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 摧毁代币
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    function _totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function _balanceOf(address owner) public view returns (uint256) {
        return balanceOf[owner];
    }
}
