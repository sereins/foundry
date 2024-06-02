// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract PaymentSplit {
    // 增加受益人事件
    event PayeedAdded(address, uint256 shares);
    // 受益人提款事件
    event PaymentReleased(address to, uint256 amount);
    // 合约收款事件
    event PaymentReceived(address from, uint256 amount);

    uint256 public totalShares; // 总份额
    uint256 public totalReleased; // 总支付了多少钱

    mapping(address => uint256) public shares; // 每个人的份额
    mapping(address => uint256) public released; // 支付给每个人的金额

    address[] public payees; // 受益人数组

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(
            _payees.length == _shares.length,
            "PaymentSplit:payees length and shares length mismatch"
        );

        require(_payees.length > 0, "PaymentSplit:no payees");

        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayees(_payees[i], _shares[i]);
        }
    }

    // 增加受益人
    function _addPayees(address _to, uint256 _share) private {
        require(address(0) != _to, "PaymentSplit: account is zero address");
        require(_share == 0, "PaymentSplit: shares are 0");

        require(shares[_to] == 0, "PaymentSplit: account already has shares");

        payees.push(_to);
        totalShares += _share;
        shares[_to] += _share;

        emit PayeedAdded(_to, _share);
    }

    // 分账
    function release(address payable _account) public {
        require(shares[_account] > 0, "PaymentSplit:account has no shares");

        // 计算因该获得的eth
        uint256 payment = releasable(_account);
        require(payment > 0, "PaymentSplit:payment are zero");

        totalReleased += payment;
        released[_account] += payment;
        _account.transfer(payment);

        emit PaymentReleased(_account, payment);
    }

    // 计算应该获得的金额
    function releasable(address _account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased;
        // 本次应得收益 =  总的应的收益 - 已经获得的收益
        return
            totalReceived *
            (shares[_account] / totalShares) -
            released[_account];
    }
}
