// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITokenListManager} from "./ITokenListManager.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TokenListManager is ITokenListManager, AccessControl {

    // Utilize EnumerableSet for efficient set operations.
    using EnumerableSet for EnumerableSet.AddressSet;

    // Define roles for administrative control and user access.
    bytes32 public constant TOKEN_MANAGER_ROLE = keccak256("TOKEN_MANAGER_ROLE");

    // Mappings for whitelisted and blacklisted tokens, categorized by token type.
    mapping(TokenType => EnumerableSet.AddressSet) private whitelistedTokens;
    mapping(TokenType => EnumerableSet.AddressSet) private blacklistedTokens;

    // Implement the addTokens method and add tokens to whitelist, only accessible by admin
    function addTokens(address[] calldata tokens, TokenType tokenType) external {
        require(hasRole(TOKEN_MANAGER_ROLE, msg.sender), "Caller is not a token manager");
        for (uint i = 0; i < tokens.length; i++) {
            // Check if the token is blacklist
            require(!blacklistedTokens[tokenType].contains(tokens[i]), "Token is blacklisted, please remove it from blacklist first");
            whitelistedTokens[tokenType].add(tokens[i]);
        }
    }

    // Implement the removeTokens method and remove tokens from whitelist, only accessible by admin
    function removeTokens(address[] calldata tokens, TokenType tokenType) external {
        require(hasRole(TOKEN_MANAGER_ROLE, msg.sender), "Caller is not a token manager");
        for (uint i = 0; i < tokens.length; i++) {
            whitelistedTokens[tokenType].remove(tokens[i]);
        }
    }

    // Implement the addBlacklistedTokens method and add tokens to blacklist, only accessible by admin
    function addBlacklistedTokens(address[] calldata tokens, TokenType tokenType) external {
        require(hasRole(TOKEN_MANAGER_ROLE, msg.sender), "Caller is not a token manager");
        for (uint i = 0; i < tokens.length; i++) {
            // Check if the token is whitelisted
            require(!whitelistedTokens[tokenType].contains(tokens[i]), "Token is whitelisted, please remove it from whitelist first");
            blacklistedTokens[tokenType].add(tokens[i]);
        }
    }

    // Implement the removeBlacklistedTokens method and remove tokens from blacklist, only accessible by admin
    function removeBlacklistedTokens(address[] calldata tokens, TokenType tokenType) external {
        require(hasRole(TOKEN_MANAGER_ROLE, msg.sender), "Caller is not a token manager");
        for (uint i = 0; i < tokens.length; i++) {
            blacklistedTokens[tokenType].remove(tokens[i]);
        }
    }

    // Implement the getWhitelistedTokens method
    function getWhitelistedTokens(TokenType tokenType, uint256 offset, uint256 limit) 
    external view returns (address[] memory, uint256) {

        // Access the set of whitelisted token addresses for the specified token type.
        EnumerableSet.AddressSet storage tokenSet = whitelistedTokens[tokenType];

        uint256 total = tokenSet.length();

        // Calculate the number of items to return, based on the provided offset and limit.
        // If the sum of offset and limit exceeds the total, return the remaining items.
        uint256 numItems = (offset + limit > total) ? total - offset : limit;
        // Initialize an array to store the addresses of the whitelisted tokens to be returned.
        address[] memory whitelisted = new address[](numItems);

        // Iterate over the token set, starting from the offset and covering the number of items calculated.
        for (uint256 i = 0; i < numItems; i++) {
            // Retrieve each token address using its index and add it to the whitelisted array.
            whitelisted[i] = tokenSet.at(offset + i);
        }

        return (whitelisted, total);
    }

    // Implement the getBlacklistedTokens method
    function getBlacklistedTokens(TokenType tokenType, uint256 offset, uint256 limit) 
    external view returns (address[] memory, uint256) {
        // The comments below all same as the getWhitelistedTokens
        EnumerableSet.AddressSet storage tokenSet = blacklistedTokens[tokenType];

        uint256 total = tokenSet.length();
        uint256 numItems = (offset + limit > total) ? total - offset : limit;
        address[] memory blacklisted = new address[](numItems);
        for (uint256 i = 0; i < numItems; i++) {
            blacklisted[i] = tokenSet.at(offset + i);
        }

        return (blacklisted, total);
    }

    // Check if a token is whitelisted
    function isWhitelisted(address token, TokenType tokenType) public view returns (bool) {
        return whitelistedTokens[tokenType].contains(token);
    }

    // Check if a token is blacklisted
    function isBlacklisted(address token, TokenType tokenType) public view returns (bool) {
        return blacklistedTokens[tokenType].contains(token);
    }
}
