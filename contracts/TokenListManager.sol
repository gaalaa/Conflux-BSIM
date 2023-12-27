// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITokenListManager} from "./ITokenListManager.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract TokenListManager is ITokenListManager {

    // Storage the token address to whitelist or blacklist
    address[] private whitelistedTokensArray;
    address[] private blacklistedTokensArray;

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
    function getWhitelistedTokens(uint256 offset, uint256 limit) 
    external view override returns (address[] memory, uint256) {
        uint256 total = whitelistedTokensArray.length;
        // Calculate the size of the returned array
        // Check if offset is greater or equal than total
        if (offset >= total) {
            // If so, return empty
            return (new address[](0), total);
        }
        // Calculate the actual quantity returned
        // Initializes numItems with the value of limit.
        uint256 numItems = limit;
        // If the sum of offset and limit is greater than total
        if (offset + limit > total) {
            // Set numItems to the remaining number of items from the offset.
            numItems = total - offset;
        }
        // Create return array
        address[] memory whitelisted = new address[](numItems);
        // Starting from offset and covering numItems
        for (uint256 i = 0; i < numItems; i++) {
            whitelisted[i] = whitelistedTokensArray[offset + i];
        }

        return (whitelisted, total);
    }

    // Implement the getBlacklistedTokens method
    function getBlacklistedTokens(uint256 offset, uint256 limit) 
    external view override returns (address[] memory, uint256) {
        uint256 total = blacklistedTokensArray.length;
        // Calculate the size of the returned array
        if (offset >= total) {
            return (new address[](0), total);
        }
        // Calculate the actual quantity returned
        uint256 numItems = limit;
        if (offset + limit > total) {
            numItems = total - offset;
        }
        // Create return array
        address[] memory blacklisted = new address[](numItems);
        for (uint256 i = 0; i < numItems; i++) {
            blacklisted[i] = blacklistedTokensArray[offset + i];
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
