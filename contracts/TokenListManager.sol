// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITokenListManager} from "./ITokenListManager.sol";

contract TokenListManager is ITokenListManager {
    
    // Use mapping to search if token in whitelist
    mapping(address => bool) private whitelistedTokens;
    // Use mapping to search if token in blacklist
    mapping(address => bool) private blacklistedTokens;

    // Implement the addTokens method and add add tokens to whitelist
    function addTokens(address[] calldata tokens) external override {
        for (uint i = 0; i < tokens.length; i++) {
            whitelistedTokens[tokens[i]] = true;
        }
    }
    // Implement the removeTokens method and add remove tokens from whitelist
    function removeTokens(address[] calldata tokens) external override {
        for (uint i = 0; i < tokens.length; i++) {
            whitelistedTokens[tokens[i]] = false;
        }
    }
    // Implement the addBlacklistedTokens method and add tokens to blacklist
    function addBlacklistedTokens(address[] calldata tokens) external override {
        for (uint i = 0; i < tokens.length; i++) {
            blacklistedTokens[tokens[i]] = true;
        }
    }
    // Implement the removeBlacklistedTokens method and remove tokens from blacklist
    function removeBlacklistedTokens(address[] calldata tokens) external override {
        for (uint i = 0; i < tokens.length; i++) {
            blacklistedTokens[tokens[i]] = false;
        }
    }
    // 
    function getWhitelistedTokens(uint256 offset, uint256 limit) external view override returns (address[] memory) {

    }
    // 
    function getBlacklistedTokens(uint256 offset, uint256 limit) external view override returns (address[] memory) {

    }
    // 
    function isWhitelisted(address token) external view override returns (bool) {
        return whitelistedTokens[token];
    }
    // 
    function isBlacklisted(address token) external view override returns (bool) {
        return blacklistedTokens[token];
    }
}
