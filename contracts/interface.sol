// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BSIMWallet {
    //此方法用于返回指定钱包地址中检测到的所有代币类型
    function detectTokenTypes(address wallet) external view returns (TokenType[] memory);
    //此方法用于获取指定钱包中指定代币的余额
    function getTokenBalance(address wallet, address token) external view returns (uint256);
    //此方法用于获取指定钱包中特定NFT的详细信息
    function getNFTDetails(address wallet, address nftAddress, uint256 tokenId) external view returns (NFTDetails memory);
    function editToken(address token, uint256 amount) external;
}

struct TokenType {
    address tokenAddress; // 代币合约地址
    string tokenType; // 代币类型，例如"ERC-20", "ERC-721", "ERC-1155"
    string name; // 代币名称
    string symbol; // 代币符号
}

struct NFTDetails {
    address nftAddress; // NFT合约地址
    uint256 tokenId; // NFT的Token ID
    string imageURL; // NFT的图像URL
    string description; // NFT的描述
}

