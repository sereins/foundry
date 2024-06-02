// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleSwap is ERC20 {
    // 代币合约
    IERC20 public token0;
    IERC20 public token1;

    constructor(IERC20 token0_, IERC20 token1_) ERC20("simple", "ss") {
        token0 = token0_;
        token1 = token1_;
    }

    // 代币的贮备量
    uint public reserve0;
    uint public reserve1;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1);
    event Swap(
        address indexed sender,
        uint amountIn,
        address tokenIn,
        uint amountOut,
        address tokenOut
    );

    function min(uint x, uint y) internal pure returns (uint z) {
        return z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function addLiquidity(
        uint amount0Desired,
        uint amount1Desired
    ) public returns (uint liquidity) {
        // 代币转给合约
        token0.transferFrom(msg.sender, address(this), amount0Desired);
        token1.transferFrom(msg.sender, address(this), amount1Desired);

        uint _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            liquidity = sqrt(amount0Desired * amount1Desired);
        } else {
            liquidity = min(
                (amount0Desired * _totalSupply) / reserve0,
                (amount1Desired * _totalSupply) / reserve1
            );
        }

        require(liquidity > 0, "insufficient liquidity mined");

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        _mint(msg.sender, liquidity);

        emit Mint(msg.sender, amount0Desired, amount1Desired);
    }

    function removeLiquidity(
        uint liquidity
    ) external returns (uint amount0, uint amount1) {
        // 获取余额
        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));
        // 按LP的比例计算要转出的代币数量
        uint _totalSupply = totalSupply();
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;
        // 检查代币数量
        require(amount0 > 0 && amount1 > 0, "INSUFFICIENT_LIQUIDITY_BURNED");
        // 销毁LP
        _burn(msg.sender, liquidity);
        // 转出代币
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
        // 更新储备量
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Burn(msg.sender, amount0, amount1);
    }

    // 给定一个资产的数量和代币对的储备，计算交换另一个代币的数量
    // 由于乘积恒定
    // 交换前: k = x * y
    // 交换后: k = (x + delta_x) * (y + delta_y)
    // 可得 delta_y = - delta_x * y / (x + delta_x)
    // 正/负号代表转入/转出
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure returns (uint amountOut) {
        require(amountIn > 0, "INSUFFICIENT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    // swap代币
    // @param amountIn 用于交换的代币数量
    // @param tokenIn 用于交换的代币合约地址
    // @param amountOutMin 交换出另一种代币的最低数量
    function swap(
        uint amountIn,
        IERC20 tokenIn,
        uint amountOutMin
    ) external returns (uint amountOut, IERC20 tokenOut) {
        require(amountIn > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
        require(tokenIn == token0 || tokenIn == token1, "INVALID_TOKEN");

        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));

        if (tokenIn == token0) {
            // 如果是token0交换token1
            tokenOut = token1;
            // 计算能交换出的token1数量
            amountOut = getAmountOut(amountIn, balance0, balance1);
            require(amountOut > amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");
            // 进行交换
            tokenIn.transferFrom(msg.sender, address(this), amountIn);
            tokenOut.transfer(msg.sender, amountOut);
        } else {
            // 如果是token1交换token0
            tokenOut = token0;
            // 计算能交换出的token1数量
            amountOut = getAmountOut(amountIn, balance1, balance0);
            require(amountOut > amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");
            // 进行交换
            tokenIn.transferFrom(msg.sender, address(this), amountIn);
            tokenOut.transfer(msg.sender, amountOut);
        }

        // 更新储备量
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Swap(
            msg.sender,
            amountIn,
            address(tokenIn),
            amountOut,
            address(tokenOut)
        );
    }
}
