// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface ITokenListManager is IERC165 {

    // Enum to distinguish between different token types
    enum TokenType {
        ERC20,
        ERC721,
        ERC1155
    }

    // Add tokens to tokenlist(whitelist), batch supported
    function addTokens(address[] calldata tokens) external;

    // Remove tokens from tokenlist(whitelist), batch supported
    function removeTokens(address[] calldata tokens) external;

    // Add tokens to blacklist, batch supported
    function addBlacklistedTokens(address[] calldata tokens) external;

    // Remove tokens from blacklist, batch supported
    function removeBlacklistedTokens(address[] calldata tokens) external;

    // Get tokens in whitelist, paging supported
    function getWhitelistedTokens(uint256 offset, uint256 limit) 
    external view returns (address[] memory whitelistedERC20Tokens, address[] memory whitelistedERC721Tokens, address[] memory whitelistedERC1155Tokens);

    // Get tokens in blacklist, paging supported
    function getBlacklistedTokens(uint256 offset, uint256 limit) 
    external view returns (address[] memory blacklistedERC20Tokens, address[] memory blacklistedERC721Tokens, address[] memory blacklistedERC1155Tokens);

    // Determine if the token in whitelist
    function isWhitelisted(address token) external view returns (bool);

    // Determine if the token in blacklist
    function isBlacklisted(address token) external view returns (bool);
}
