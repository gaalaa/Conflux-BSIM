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
interface IPriceFeed {
    // 获取代币价格
    function getPrice(address tokenAddress) external view returns (uint256);
}

// 获取代币余额及其市场价值
contract TokenInfoInterface {
    IPriceFeed priceFeed;

    constructor(address _priceFeedAddress) {
        priceFeed = IPriceFeed(_priceFeedAddress);
    }

    // 获取给定用户的代币余额、符号、名称和value
    function getTokenBalancesAndValues(address user, address[] calldata tokenAddresses) 
        external view returns (uint256[] memory balances, string[] memory symbols, string[] memory names, uint256[] memory values) {

        balances = new uint256[](tokenAddresses.length);
        symbols = new string[](tokenAddresses.length);
        names = new string[](tokenAddresses.length);
        values = new uint256[](tokenAddresses.length);

        // 循环每个token地址来获取以下信息，并计算出余额
        for (uint i = 0; i < tokenAddresses.length; i++) {
            IERC20 token = IERC20(tokenAddresses[i]);
            balances[i] = token.balanceOf(user);
            symbols[i] = token.symbol();
            names[i] = token.name();
            // 计算并存储用户代币余额
            values[i] = balances[i] * priceFeed.getPrice(tokenAddresses[i]);
        }
    }
}
