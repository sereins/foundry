// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {IERC20} from "../lib/forge-std/src/interfaces/IERC20.sol";

contract AirDrop {
    // 发送失败的交易
    mapping(address => uint256) failTransferList;

    function multiTransferToken(
        address _token,
        address[] calldata _address,
        uint[] calldata _amount
    ) public {
        require(
            _address.length == _amount.length,
            "Length of Address and Amounts Not Equal!"
        );

        IERC20 token = IERC20(_token);

        uint _amountSum = getSUm(_amount);
        require(
            token.allowance(msg.sender, address(this)) > _amountSum,
            "Need Approve ERC20 token"
        );

        for (uint256 index = 0; index < _address.length; index++) {
            token.transferFrom(msg.sender, _address[index], _amount[index]);
        }
    }

    // 向多个地址发放ETH
    function multiTransferETH(
        address payable[] calldata _address,
        uint256[] calldata _amounts
    ) public payable {
        require(
            _address.length == _amounts.length,
            "Length of Address and Amounts Not Equal!"
        );

        uint _amountSum = getSUm(_amounts);
        require(msg.value == _amountSum, "Transfer amoutn err");

        for (uint256 index = 0; index < _address.length; index++) {
            // 转转
            (bool success, ) = _address[index].call{value: _amounts[index]}("");

            // 失败
            if (!success) failTransferList[_address[index]] = _amounts[index];
        }
    }

    // 失败的主动领空投
    function withDrawFromFailList(address _to) public {
        uint failAmount = failTransferList[msg.sender];
        require(failAmount > 0, "You are not in failList");

        failTransferList[msg.sender] = 0;
        (bool success, ) = _to.call{value: failAmount}("");
        require(success, "Fail withDraw");
    }

    // 求发的总代币
    function getSUm(uint256[] calldata _arr) public pure returns (uint256 sum) {
        for (uint i = 0; i < _arr.length; i++) sum = sum + _arr[i];
    }
}
