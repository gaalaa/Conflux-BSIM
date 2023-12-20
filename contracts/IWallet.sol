// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IWallet {

    // structed other information
    struct TokenInfo {
        address tokenAddress;
        uint256 balance;
        string name;
        string symbol;
        uint8 decimals;
    }

    // Get token market price
    function getTokenMarketPrice(address token) external view returns (uint256);

    // Get paginated token information
    function getPaginatedTokenInfo(address user, uint start, uint limit) external view returns (TokenInfo[] memory tokensInfo);
}
