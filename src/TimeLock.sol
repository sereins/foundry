// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract TimeLock {
    event CancelTransation(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint excuteTime
    );

    event ExcuteTransation(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint excuteTime
    );

    event QueueTransation(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint excuteTime
    );

    event NewAdmin(address newAdmin);

    address public admin;
    uint public constant GRACE_PERIOD = 7 days;
    uint public delay;
    mapping(bytes32 => bool) public queueTransations;

    modifier onlyOwner() {
        require(msg.sender == admin, "TimeLock:Caller not owner");
        _;
    }

    modifier onlyTimelock() {
        require(msg.sender == address(this), "TimeLock: Caller not Timelock");
        _;
    }

    constructor(uint _delay) {
        delay = _delay;
        admin = msg.sender;
    }

    function changeAdmin(address _newAdmin) public onlyTimelock {
        require(_newAdmin != address(0), "TimeLock:new address is zero");
        admin = _newAdmin;
        emit NewAdmin(_newAdmin);
    }

    function queueTransation(
        address traget,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
    ) public onlyOwner returns (bytes32) {
        require(
            executeTime >= block.timestamp + delay,
            "TimeLock:execution block must satisfy delay"
        );
        bytes32 txHash = getTxHash(traget, value, signature, data, executeTime);
        require(
            queueTransations[txHash] == false,
            "TimeLock::queueTransation: tx already exists."
        );

        queueTransations[txHash] = true;
        return txHash;
    }

    // 取消交易
    function cancelTransation(
        address traget,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
    ) public onlyOwner {
        bytes32 txHash = getTxHash(traget, value, signature, data, executeTime);

        require(
            queueTransations[txHash],
            "TimeLock::queueTransation: transation hasn't been queue"
        );

        queueTransations[txHash] = false;

        emit CancelTransation(
            txHash,
            traget,
            value,
            signature,
            data,
            executeTime
        );
    }

    // 执行交易
    function executeTransation(
        address traget,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
    ) public onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(traget, value, signature, data, executeTime);

        require(
            queueTransations[txHash],
            "TimeLock::exectute: transation hasn't been queue"
        );

        require(
            block.timestamp >= executeTime,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );
        // 检查：交易没过期
        require(
            block.timestamp <= executeTime + GRACE_PERIOD,
            "Timelock::executeTransaction: Transaction is stale."
        );

        queueTransations[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            // 这里如果采用encodeWithSignature的编码方式来实现调用管理员的函数，请将参数data的类型改为address。不然会导致管理员的值变为类似"0x0000000000000000000000000000000000000020"的值。其中的0x20是代表字节数组长度的意思.
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
        }
        // 利用call执行交易
        (bool success, bytes memory returnData) = traget.call{value: value}(
            callData
        );
        require(
            success,
            "Timelock::executeTransaction: Transaction execution reverted."
        );

        emit ExcuteTransation(
            txHash,
            traget,
            value,
            signature,
            data,
            executeTime
        );

        return returnData;
    }

    // 计算交易的hash
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encode(target, value, signature, data, executeTime));
    }
}
