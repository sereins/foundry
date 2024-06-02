// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Test, console2} from "forge-std/Test.sol";
import {NFTSwap} from "../src/NFTSwap.sol";
import {MyERC731Ape} from "../src/MyERC731Ape.sol";
import {IERC721Receiver} from "forge-std/interfaces/IERC721Receiver.sol";

contract NFTSwaptest is Test, IERC721Receiver {
    NFTSwap swap;

    function setUp() public {
        swap = new NFTSwap();
    }

    // 铸币: address 0 有两个nft
    function init() internal returns (address) {
        MyERC731Ape nft = new MyERC731Ape("TB", "TB");
        nft.mint(address(this), 0);
        nft.mint(address(this), 1);

        // 进行授权
        nft.approve(address(swap), 0);
        nft.approve(address(swap), 1);
        return address(nft);
    }

    // 挂单
    function testList() public {
        address nft = init();
        swap.list(nft, 0, 100);

        (address owner, uint256 price) = swap.getNFTOrder(nft, 0);

        assertEq(address(this), owner);
        assertEq(100, price);
    }

    // 修改价格
    function testUpdate() public {
        address nft = init();
        swap.list(nft, 0, 100);

        swap.update(nft, 0, 1);
        (address owner, uint256 price) = swap.getNFTOrder(nft, 0);

        assertEq(address(this), owner);
        assertEq(1, price);
    }

    // 撤销挂单
    function testRevoke() public {
        address nft = init();
        swap.list(nft, 0, 100);

        swap.revoke(nft, 0);

        (address owner, uint256 price) = swap.getNFTOrder(nft, 0);

        assertEq(address(0), owner);
        assertEq(0, price);
    }

    function testPurchase() public {
        address nft = init();
        swap.list(nft, 0, 100);

        uint256 balance1 = address(this).balance;
        address alice = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        vm.prank(alice);
        swap.purchase{value: 200}(nft, 0);

        // 验证卖家是否收到钱了
        assertEq(balance1 + 100, address(this).balance);

        // 验证买家是否收到币了
        MyERC731Ape erc721 = MyERC731Ape(nft);
        assertEq(erc721.ownerOf(0), alice);
    }

    // 测试方便编写的函数
    receive() external payable {}

    fallback() external payable {}

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        return IERC721Receiver(address(this)).onERC721Received.selector;
    }
}
