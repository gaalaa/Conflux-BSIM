// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20接口，Token list
interface IERC20 {
    // 获取给定帐户的代币余额
    function balanceOf(address account) external view returns (uint256);
    // 返回代币符号
    function symbol() external view returns (string memory);
    // 返回代币名称
    function name() external view returns (string memory);
}

//PriceFeed接口，资产查询
interface IPriceInquire {
    // 获取代币价格
    function getPrice(address tokenAddress) external view returns (uint256);
}
