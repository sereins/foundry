// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract MultiSigWallet {
    event ExecutionSuccess(bytes32 txHash);
    event ExecutionFailure(bytes32 txHash);

    address[] public owners; // 多签人持有数组
    mapping(address => bool) public isOwner;

    uint256 public ownerCount;
    uint256 public threshold;
    uint256 public nonce;

    receive() external payable {}

    constructor(address[] memory _owners, uint256 _threshold) {
        setUpOwners(_owners, _threshold);
    }

    function setUpOwners(
        address[] memory _owners,
        uint256 _threshold
    ) internal {
        require(threshold == 0, "threshold not 0");
        require(_threshold > 0, "_threshold is 0");
        require(_threshold < _owners.length, "_threshold grate than owners");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(
                owner != address(0) &&
                    owner != address(this) &&
                    !isOwner[owner],
                "address error"
            );

            owners.push(owner);
            isOwner[owner] = true;
        }

        ownerCount = _owners.length;
        threshold = _threshold;
    }

    // 执行交易
    function execTransaction(
        address to,
        uint256 value,
        bytes memory data,
        bytes memory signatures
    ) public payable returns (bool success) {
        // 编码交易数据，计算哈希
        bytes32 txHash = encodeTransactionData(
            to,
            value,
            data,
            nonce,
            block.chainid
        );
        nonce++; // 增加nonce
        checkSignatures(txHash, signatures); // 检查签名
        // 利用call执行交易，并获取交易结果
        (success, ) = to.call{value: value}(data);
        require(success, "WTF5004");
        if (success) emit ExecutionSuccess(txHash);
        else emit ExecutionFailure(txHash);
    }

    // 交易签名
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        uint256 _nonce,
        uint256 chainid
    ) public pure returns (bytes32) {
        bytes32 safeTxHash = keccak256(
            abi.encode(to, value, keccak256(data), _nonce, chainid)
        );

        return safeTxHash;
    }

    // 验证签名
    function checkSignatures(
        bytes32 dataHash,
        bytes memory signatures
    ) public view {
        // 需要几个验证
        uint256 _threshold = threshold;
        require(_threshold > 0, "_threshold errror");
        require(signatures.length >= _threshold, "signature length not enough");

        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            // 利用ecrecover检查签名是否有效
            currentOwner = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        dataHash
                    )
                ),
                v,
                r,
                s
            );
            require(
                currentOwner > lastOwner && isOwner[currentOwner],
                "WTF5007"
            );
            lastOwner = currentOwner;
        }
    }

    function signatureSplit(
        bytes memory signature,
        uint256 pos
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        assembly {
            let signatursPos := mul(0x41, pos)
            r := mload(add(signature, add(signatursPos, 0x20)))
            s := mload(add(signature, add(signatursPos, 0x40)))
            v := and(mload(add(signature, add(signatursPos, 0x41))), 0xff)
        }
    }
}
