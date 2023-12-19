// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//PriceInquire接口，资产查询
interface IPriceInquire {
    // 获取代币价格
    function getPrice(address tokenAddress) external view returns (uint256);
}