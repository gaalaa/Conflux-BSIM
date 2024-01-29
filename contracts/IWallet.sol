// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./ITokenListManager.sol";

    // structed other information
    struct TokenInfo {
        address tokenAddress;
        uint256 balance;
        string name;
        string symbol;
        uint8 decimals;
    }

    // Hold both paginated tokens and the total count
    struct PaginatedTokenInfo {
        TokenInfo[] tokens;
        uint256 total;
    }
    
interface IWallet {

    // Get paginated token information
    function getPaginatedTokenInfo(TokenType tokenType, address user, uint start, uint limit) 
    external view returns (PaginatedTokenInfo memory);
}
