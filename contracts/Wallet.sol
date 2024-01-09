// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IWallet} from "./IWallet.sol";

contract Wallet is IWallet {
    // Implement getTokenMarketPrice method
    function getTokenMarketPrice(address token) external view override returns (uint256) {

    }

    // Implement getPaginatedTokenInfo method
    function getPaginatedTokenInfo(address user, uint start, uint limit) external view override returns (TokenInfo[] memory tokensInfo) {

    }
}
