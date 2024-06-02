// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract FunctionType {
    uint256 public number;

    // 函数类型                      修饰可见行                  限定权限 view 只读不修改,pure 不读不修改 payable 可支付
    // function (<parameter types>) {internal|external|public} [pure|view|payable] [returns (<return types>)]
    // 默认function
    function add() external {
        number = number + 1;
    }

    // pure
    function pur(uint256 _number) public pure returns (uint256 newNumber) {
        require(_number < type(uint256).max);
        newNumber = _number + 1;
    }

    // view
    function views() public view returns (uint256) {
        return number;
    }

    function minus() internal {
        number = number + 1;
    }

    // 调用合约内部函数
    function minusCall() external {
        minus();
    }

    // payable
    function minusPay() external payable returns (uint256 balance) {
        balance = address(this).balance;
    }
}
