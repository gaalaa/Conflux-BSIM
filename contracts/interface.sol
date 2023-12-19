// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface BSIMWallet {
    //此方法用于返回指定钱包地址中检测到的所有代币类型
    function detectTokenTypes(address wallet) external view returns (TokenType[] memory);
    //此方法用于获取指定钱包中指定代币的余额
    function getTokenBalance(address wallet, address token) external view returns (uint256);
}

struct TokenType {
    address tokenAddress; // 代币合约地址
    string tokenType; // 代币类型，"ERC-20"
    string name; // 代币名称
    string symbol; // 代币符号
}
