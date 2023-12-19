// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenListManager {

    // add token to tokenlist
    function addToken(address token) external;

    // remove token from tokenlist
    function removeToken(address token) external;

    // add token to whitelist
    function addTokenToWhitelist(address token) external;

    // remove token from whitelist
    function removeTokenFromWhitelist(address token) external;

    // add token to blacklist
    function addTokenToBlacklist(address token) external;

    // remove token from blacklist
    function removeTokenFromBlacklist(address token) external;

    // search token in whitelist
    function getWhitelistedTokens() external view returns (address[] memory);

    // search token in blacklist
    function getBlacklistedTokens() external view returns (address[] memory);
}