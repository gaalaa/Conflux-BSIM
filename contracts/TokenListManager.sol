// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITokenListManager} from "./ITokenListManager.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract TokenListManager is ITokenListManager {

    // Storage the token address to whitelist or blacklist
    address[] private whitelistedTokensArray;
    address[] private blacklistedTokensArray;
    // Declare arrays to store addresses of whitelisted tokens by type
    address[] private whitelistErc20Tokens;
    address[] private whitelistErc721Tokens;
    address[] private whitelistErc1155Tokens;
    // Declare arrays to store addresses of blacklisted tokens by type
    address[] private blacklistErc20Tokens;
    address[] private blacklistErc721Tokens;
    address[] private blacklistErc1155Tokens;

    // Use mapping to check if token in whitelist
    mapping(address => bool) private whitelistedTokens;
    // Use mapping to check if token in blacklist
    mapping(address => bool) private blacklistedTokens;

    // Set permissions
    modifier onlyOwner() {
        // Match address
        /** 0xC0Ec75c25EC201885a791Fd8d39Bf8CE96e1c566
         * this address is my own test address
         * owner can use thier own address to replace. */
        require(msg.sender == 0xC0Ec75c25EC201885a791Fd8d39Bf8CE96e1c566, "Not authorized");
        _;
    }

    // Implement the addTokens method and add tokens to whitelist
    function addTokens(address[] calldata tokens) external override onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            // Check if the token is not already whitelisted
            if (!whitelistedTokens[tokens[i]]) {
                // If the token type is ERC-20
                if (IERC165(tokens[i]).supportsInterface(type(IERC20).interfaceId)) {
                    // Storage to whitelistErc20Tokens
                    whitelistErc20Tokens.push(tokens[i]);
                // If the token type is IERC-721
                } else if (IERC165(tokens[i]).supportsInterface(type(IERC721).interfaceId)) {
                    // Storage to whitelistErc721Tokens
                    whitelistErc721Tokens.push(tokens[i]);
                // If the token type is IERC-1155
                } else if (IERC165(tokens[i]).supportsInterface(type(IERC1155).interfaceId)) {
                    // Storage to whitelistErc1155Tokens
                    whitelistErc1155Tokens.push(tokens[i]);
                } else {
                    revert("Unsupported token type");
                }
                // Mark the token address as whitelisted in the mapping
                whitelistedTokens[tokens[i]] = true;
                // Add the token address to the array of whitelisted tokens
                whitelistedTokensArray.push(tokens[i]);
            }
        }
    }

    // Implement the removeTokens method and remove tokens from whitelist
    function removeTokens(address[] calldata tokens) external override onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            // Check if the token in whitelist
            if (whitelistedTokens[tokens[i]]) {
                // Remove each token address from whitelist
                whitelistedTokens[tokens[i]] = false;
                // Call internal function below to remove from the array
                removeTokenFromWhitelistArray(tokens[i]);
            }
        }
    }

    // The internal function that to remove token from whitelist array (Reduce gas)
    function removeTokenFromWhitelistArray(address token) internal {
        for (uint i = 0; i < whitelistedTokensArray.length; i++) {
            if (whitelistedTokensArray[i] == token) {
                // Swap the token with last element in whitelistedTokensArray
                whitelistedTokensArray[i] = whitelistedTokensArray[whitelistedTokensArray.length - 1];
                // Remove to last element
                whitelistedTokensArray.pop();
                break;
            }
        }
    }


    // Implement the addBlacklistedTokens method and add tokens to blacklist
    function addBlacklistedTokens(address[] calldata tokens) external override onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            // Check if the token is not already blacklisted
            if (!blacklistedTokens[tokens[i]]) {
                // If the token type is ERC-20
                if (IERC165(tokens[i]).supportsInterface(type(IERC20).interfaceId)) {
                    // Storage to blacklistErc20Tokens
                    blacklistErc20Tokens.push(tokens[i]);
                // If the token type is IERC-721
                } else if (IERC165(tokens[i]).supportsInterface(type(IERC721).interfaceId)) {
                    // Storage to blacklistErc721Tokens
                    blacklistErc721Tokens.push(tokens[i]);
                // If the token type is IERC-1155
                } else if (IERC165(tokens[i]).supportsInterface(type(IERC1155).interfaceId)) {
                    // Storage to blacklistErc1155Tokens
                    blacklistErc1155Tokens.push(tokens[i]);
                } else {
                    revert("Unsupported token type");
                }
                // Mark the token address as blacklisted in the mapping
                blacklistedTokens[tokens[i]] = true;
                // Add the token address to the array of blacklisted tokens
                blacklistedTokensArray.push(tokens[i]);
            }
        }
    }

    // Implement the removeBlacklistedTokens method and remove tokens from blacklist
    function removeBlacklistedTokens(address[] calldata tokens) external override onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            if (blacklistedTokens[tokens[i]]) {
                // Remove each token address from blacklist
                blacklistedTokens[tokens[i]] = false;
                // Remove from the array
                removeTokenFromBlacklistArray(tokens[i]);
            }
        }
    }
    
    // The internal function that to remove token from blacklist array (Reduce gas)
    function removeTokenFromBlacklistArray(address token) internal {
        for (uint i = 0; i < blacklistedTokensArray.length; i++) {
            if (blacklistedTokensArray[i] == token) {
                // Swap the token with last element in blacklistedTokensArray
                blacklistedTokensArray[i] = blacklistedTokensArray[blacklistedTokensArray.length - 1];
                // Remove to last element
                blacklistedTokensArray.pop();
                break;
            }
        }
    }

    // Implement the getWhitelistedTokens method
    function getWhitelistedTokens(TokenType tokenType, uint256 offset, uint256 limit) 
    external view returns (address[] memory, uint256) {
        
        address[] storage tokenArray;

        // Determine which token array to use based on the tokenType parameter
        if (tokenType == TokenType.ERC20) {
            tokenArray = whitelistErc20Tokens; // Point to ERC-20 tokens array
        } else if (tokenType == TokenType.ERC721) {
            tokenArray = whitelistErc721Tokens; // Point to ERC-721 tokens array
        } else if (tokenType == TokenType.ERC1155) {
            tokenArray = whitelistErc1155Tokens; // Point to ERC-1155 tokens array
        } else {
            revert("Invalid token type");
        }

        uint256 total = tokenArray.length;
        // Calculate the size of the returned array
        // Check if offset is greater or equal than total
        if (offset >= total) {
            // If so, return empty
            return (new address[](0), total);
        }

        // Calculate the number of items to return, adjusting for the case where offset + limit exceeds total
        uint256 numItems = (offset + limit > total) ? total - offset : limit;
        // Create an array to hold the returned token address
        address[] memory whitelisted = new address[](numItems);
        for (uint256 i = 0; i < numItems; i++) {
            whitelisted[i] = tokenArray[offset + i];
        }

        return (whitelisted, total);
    }

    // Implement the getBlacklistedTokens method
    function getBlacklistedTokens(TokenType tokenType, uint256 offset, uint256 limit) 
    external view returns (address[] memory, uint256) {
        
        address[] storage tokenArray;

        // Determine which token array to use based on the tokenType parameter
        if (tokenType == TokenType.ERC20) {
            tokenArray = blacklistErc20Tokens;
        } else if (tokenType == TokenType.ERC721) {
            tokenArray = blacklistErc721Tokens;
        } else if (tokenType == TokenType.ERC1155) {
            tokenArray = blacklistErc1155Tokens;
        } else {
            revert("Invalid token type");
        }

        uint256 total = tokenArray.length;
        // Calculate the size of the returned array
        if (offset >= total) {
            return (new address[](0), total);
        }

        // Calculate the number of items to return, adjusting for the case where offset + limit exceeds total
        uint256 numItems = (offset + limit > total) ? total - offset : limit;
        // Create an array to hold the returned token address
        address[] memory blacklisted = new address[](numItems);
        for (uint256 i = 0; i < numItems; i++) {
            blacklisted[i] = tokenArray[offset + i];
        }

        return (blacklisted, total);
    }

    // Implement the isWhitelisted method and check weather the token is in whitelist
    function isWhitelisted(address token) external view override returns (bool) {
        return whitelistedTokens[token];
    }

    // Implement the isBlacklisted method and check weather the token is in blacklist
    function isBlacklisted(address token) external view override returns (bool) {
        return blacklistedTokens[token];
    }
}
