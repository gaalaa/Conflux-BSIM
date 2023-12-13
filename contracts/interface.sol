// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenWallet {
    //function detectTokenTypes(address wallet) external view returns (TokenType[] memory);
    function getTokenBalance(address wallet, address token) external view returns (uint256);
    //function getNFTDetails(address wallet, address nftAddress, uint256 tokenId) external view returns (NFTDetails memory);
    function editToken(address token, uint256 amount) external; // 具体参数取决于编辑操作的需求
}

// 可能需要的辅助数据结构
//struct TokenType {
    // ... 代币类型的详细信息
//}

//struct NFTDetails {
    // ... NFT的详细信息，例如图片URL和描述
//}
