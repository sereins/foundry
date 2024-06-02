// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SignatureNFT is ERC721 {
    address public immutable signer;
    mapping(address => bool) public mintedAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address _signer
    ) ERC721(_name, _symbol) {
        signer = _signer;
    }

    // 铸币
    function mint(
        address _account,
        uint256 _tokenId,
        bytes memory _signature
    ) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _ethMsgHash = ECDSA.toEthSignedMessageHash(_msgHash);

        require(verify(_ethMsgHash, _signature), "invalid signature");
        require(!mintedAddress[_account], "alreay minted!");

        mintedAddress[_account] = true;
        _mint(_account, _tokenId);
    }

    function getMessageHash(
        address _account,
        uint256 _tokenId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    // 验证签名
    function verify(
        bytes32 _msgHash,
        bytes memory _signature
    ) public view returns (bool) {
        return ECDSA.verify(_msgHash, _signature, signer);
    }
}

// 验证签名:合约
contract VerifySignature {
    // 获取消息的hash，这里使用参数 address h和 tokenId
    function getMessageHash(
        address _addr,
        uint256 _tokenId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_addr, _tokenId));
    }

    // 以太坊签名消息
    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    // 验证签名
    function verify(
        address _signer,
        address _addr,
        uint _tokenId,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_addr, _tokenId);
        bytes32 ethMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethMessageHash, signature) == _signer;
    }

    // 恢复签名者的地址
    function recoverSigner(
        bytes32 _ethSignedMessage,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessage, v, r, s);
    }

    // 从签名中解析出 r s v
    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
    }
}

library ECDSA {
    // 验证签名地址是否正确
    function verify(
        bytes32 _msgHash,
        bytes memory _signature,
        address _signer
    ) internal pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    // 从签名消息和签名中恢复地址
    function recoverSigner(
        bytes32 _msgHash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.length == 65, "invalid signature lenght");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
        return ecrecover(_msgHash, v, r, s);
    }

    /**
      以太坊签名消息 :防止签名的是可执行交易,在原本的签名上再加一层
    */
    function toEthSignedMessageHash(
        bytes32 hash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}
