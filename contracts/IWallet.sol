// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./ITokenListManager.sol";

interface IWallet {

    // structed other information
    struct TokenInfo {
        address tokenAddress;
        uint256 balance;
        string name;
        string symbol;
        uint8 decimals;
    }

    // Get paginated token information
    function getPaginatedTokenInfo(TokenType tokenType, address user, uint start, uint limit) 
    external view returns (TokenInfo[] memory tokensInfo);
}
