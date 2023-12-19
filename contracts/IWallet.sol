// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IWallet {

    // register(add) token to user's wallet
    function registerToken(address user, address token) external;

    // inquire token's market price
    function getTokenMarketPrice(address user, address token) external view returns (uint256);

    // get paginated token balance
    function getPaginatedTokenBalances(address user, uint start, uint limit) 
    external view returns (address[] memory tokenAddresses, uint256[] memory balances);
}
