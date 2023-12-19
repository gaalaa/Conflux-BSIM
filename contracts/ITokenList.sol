// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenList {
    // add to whitelist
    function addTokenToWhitelist(address token) external;

    // remove from whitelist
    function removeTokenFromWhitelist(address token) external;

    // add to blacklist
    function addTokenToBlacklist(address token) external;

    // search token in whitelist
    function getWhitelistedTokens() external view returns (address[] memory);

    // search toke in blacklist
    function getBlacklistedTokens() external view returns (address[] memory);
}
