// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IExtendedERC20.sol";
import "./IWallet.sol";
import "./TokenListManager.sol";

contract Wallet is IWallet {
    TokenListManager public tokenListManager;

    constructor(address _tokenListManager) {
        tokenListManager = TokenListManager(_tokenListManager);
    }

    function getPaginatedTokenInfo(address user, uint start, uint limit) 
    external view override returns (TokenInfo[] memory tokensInfo) {
        // Get ERC-20 info
        address[] memory erc20Tokens = tokenListManager.getWhitelistedTokens(TokenType.ERC20, start, limit);
        // Get ERC-721 token info
        address[] memory erc721Tokens = tokenListManager.getWhitelistedTokens(TokenType.ERC721, start, limit);
        // Get ERC-1155 token info
        address[] memory erc1155Tokens = tokenListManager.getWhitelistedTokens(TokenType.ERC1155, start, limit);

        // Count total of the token
        uint256 totalTokens = erc20Tokens.length + erc721Tokens.length + erc1155Tokens.length;
        TokenInfo[] memory paginatedInfo = new TokenInfo[](totalTokens);
        uint256 count = 0;

        // Fill in ERC-20 token information
        for (uint256 i = 0; i < erc20Tokens.length; i++) {
            IExtendedERC20 token = IExtendedERC20(erc20Tokens[i]);
            paginatedInfo[count++] = TokenInfo({
                tokenAddress: erc20Tokens[i],
                balance: token.balanceOf(user),
                name: token.name(),
                symbol: token.symbol(),
                decimals: token.decimals()
            });
        }

        // Fill in ERC-721 token information
        for (uint256 i = 0; i < erc721Tokens.length; i++) {
            paginatedInfo[count++] = TokenInfo({
                tokenAddress: erc721Tokens[i],
                balance: 0,
                name: "",
                symbol: "",
                decimals: 0
            });
        }

        // Fill in ERC-1155 token information
        for (uint256 i = 0; i < erc1155Tokens.length; i++) {
            paginatedInfo[count++] = TokenInfo({
                tokenAddress: erc1155Tokens[i],
                balance: 0, // Need tokenID
                name: "",
                symbol: "",
                decimals: 0
            });
        }

        return paginatedInfo;
    }
}
