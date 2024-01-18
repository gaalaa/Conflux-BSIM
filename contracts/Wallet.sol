// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IWallet.sol";
import "./TokenListManager.sol";

contract Wallet is IWallet {
    TokenListManager public tokenListManager;

    constructor(address _tokenListManager) {
        tokenListManager = TokenListManager(_tokenListManager);
    }

    // Make a private method to fetch token info
    function getTokenInfo(address tokenAddress, TokenType tokenType, address user)
    private view returns (TokenInfo memory) {
        TokenInfo memory info;

        // Fill in ERC-20 token information
        if (tokenType == TokenType.ERC20) {
            IERC20Metadata token = IERC20Metadata(tokenAddress);
            uint256 balance = token.balanceOf(user);

            // Filter tokens with a balance of 0 in ERC-20
            if (balance > 0) {
                info = TokenInfo({
                    tokenAddress: tokenAddress,
                    balance: token.balanceOf(user),
                    name: token.name(),
                    symbol: token.symbol(),
                    decimals: token.decimals()
                });
            }

        // Fill in ERC-721 token information
        } else if (tokenType == TokenType.ERC721) {
            IERC721Metadata token = IERC721Metadata(tokenAddress);
            info = TokenInfo({
                tokenAddress: tokenAddress,
                balance: token.balanceOf(user),
                name: token.name(),
                symbol: token.symbol(),
                decimals: 0 // ERC721 tokens do not have decimals
            });

        // Fill in ERC-1155 token information
        } else if (tokenType == TokenType.ERC1155) {
            IERC1155 token = IERC1155(tokenAddress);
            // The token ID is needed to get the correct balance
            // Assuming a token ID is provided or known
            uint256 tokenId = 1; // Token ID needs to be determined, 1 is an example
            info = TokenInfo({
                tokenAddress: tokenAddress,
                balance: token.balanceOf(user, tokenId),
                name: "",   // Name and symbol are not standard in ERC1155
                symbol: "",
                decimals: 0 // Decimals are not standard in ERC1155
            });
        }

        return info;
    }
    
    // Implement getPaginatedTokenInfo method
    function getPaginatedTokenInfo(TokenType tokenType, address user, uint start, uint limit) 
    external view override returns (TokenInfo[] memory tokensInfo){
        address[] memory tokenAddresses = tokenListManager.getWhitelistedTokens(tokenType, start, limit);
        TokenInfo[] memory tempInfo = new TokenInfo[](tokenAddresses.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            TokenInfo memory info = getTokenInfo(tokenAddresses[i], tokenType, user);
            if (info.balance > 0) {  // Only include tokens with non-zero balance
                tempInfo[count] = info;
                count++;
            }
        }
        TokenInfo[] memory paginatedInfo = new TokenInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            paginatedInfo[i] = tempInfo[i];
        }

        return paginatedInfo;
    }

    // Add api to return assets for specified address list.
    function getTokenInfoForAddresses(address[] calldata addresses, TokenType tokenType) 
    external view returns (TokenInfo[] memory) {
        TokenInfo[] memory infos = new TokenInfo[](addresses.length);

        for (uint i = 0; i < addresses.length; i++) {
            infos[i] = getTokenInfo(addresses[i], tokenType, msg.sender);
        }

        return infos;
    }
}
