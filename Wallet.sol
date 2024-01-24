// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/ICRC1155Metadata.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/ICRC1155Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "./IWallet.sol";
import "./TokenListManager.sol";

contract Wallet is IWallet {

    using ERC165Checker for address;

    TokenListManager public tokenListManager;

    constructor(address _tokenListManager) {
        tokenListManager = TokenListManager(_tokenListManager);
    }

    // Private helper function to determine the type of token
    function getTokenType(address tokenAddress) private view returns (TokenType) {
        // Checking the token's interface via ERC165
        if (tokenAddress.supportsInterface(type(IERC721).interfaceId)) {
            return TokenType.ERC721;
        } else if (tokenAddress.supportsInterface(type(IERC1155).interfaceId)) {
            return TokenType.ERC1155;
        } else {
            return TokenType.ERC20; // Defaults to ERC-20 if not ERC-721 or ERC-1155
        }
    }

    // Private function to get information about a token
    function getTokenInfo(address tokenAddress, address user) private view returns (TokenInfo[] memory) {
        TokenType tokenType = getTokenType(tokenAddress);
        TokenInfo[] memory infos = new TokenInfo[](0);
        // Handling for ERC20 tokens: Fetches balance, name, symbol, and decimals.
        // Only includes the token if the user has a non-zero balance
        if (tokenType == TokenType.ERC20) {
            IERC20Metadata token = IERC20Metadata(tokenAddress);
            uint256 balance = token.balanceOf(user);
            if (balance > 0) {
                infos = new TokenInfo[](1);
                infos[0] = TokenInfo({
                    tokenAddress: tokenAddress,
                    balance: balance,
                    name: token.name(),
                    symbol: token.symbol(),
                    decimals: token.decimals()
                });
            }
        // Handling for ERC721 tokens: Fetches balance, name, and symbol.
        } else if (tokenType == TokenType.ERC721) {
            IERC721Metadata token = IERC721Metadata(tokenAddress);
            uint256 balance = token.balanceOf(user);
            if (balance > 0) {
                infos = new TokenInfo[](1);
                infos[0] = TokenInfo({
                    tokenAddress: tokenAddress,
                    balance: balance,
                    name: token.name(),
                    symbol: token.symbol(),
                    decimals: 0 // Set decimals to 0
                });
            }
        } else if (tokenType == TokenType.ERC1155) {
            ICRC1155Enumerable tokenEnumerable = ICRC1155Enumerable(tokenAddress);
            ICRC1155Metadata tokenMetadata = ICRC1155Metadata(tokenAddress);
            uint256 tokenCount = tokenEnumerable.tokenCountOf(user);

            if (tokenCount > 0) {
                infos = new TokenInfo[](1);
                infos[0] = TokenInfo({
                    tokenAddress: tokenAddress,
                    balance: tokenCount, // Here the balance is the count of distinct token IDs
                    name: tokenMetadata.name(),   // Use name from ICRC1155Metadata
                    symbol: tokenMetadata.symbol(), // Use symbol from ICRC1155Metadata
                    decimals: 0 // Set decimals to 0 for NFTs
                });
            }
        }

        return infos;
    }

    // Public function to get paginated token information
    function getPaginatedTokenInfo(TokenType tokenType, address user, uint start, uint limit) 
    external view override returns (TokenInfo[] memory tokensInfo) {
        // Fetches all whitelisted tokens from the TokenListManager based on the token type
        address[] memory allTokenAddresses = tokenListManager.getAllWhitelistedTokens(tokenType);
        TokenInfo[] memory allInfos = new TokenInfo[](allTokenAddresses.length);
        uint256 totalInfosCount = 0;
        
        // Filter out tokens with non-zero balance
        for (uint256 i = 0; i < allTokenAddresses.length; i++) {
            TokenInfo[] memory infos = getTokenInfo(allTokenAddresses[i], user);
            for (uint256 j = 0; j < infos.length; j++) {
                if (infos[j].balance > 0) {
                    allInfos[totalInfosCount++] = infos[j];
                }
            }
        }
        // Applying pagination
        uint256 paginatedSize = totalInfosCount > start ? min(totalInfosCount - start, limit) : 0;
        TokenInfo[] memory paginatedInfo = new TokenInfo[](paginatedSize);
        for (uint256 i = 0; i < paginatedSize; i++) {
            paginatedInfo[i] = allInfos[start + i];
        }

        return paginatedInfo;
    }

    // Helper function to find minimum of two uint values
    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }

    // Public function to get token information for a list of addresses.
    // Fetching token data across multiple addresses at once.
    function getTokenInfoForAddresses(address[] calldata addresses, address user) 
    external view returns (TokenInfo[] memory) {
        // Adjusted to handle arrays returned by getTokenInfo
        uint256 totalInfosCount = 0;
        for (uint i = 0; i < addresses.length; i++) {
            totalInfosCount += getTokenInfo(addresses[i], user).length;
        }

        TokenInfo[] memory infos = new TokenInfo[](totalInfosCount);
        uint256 currentInfoIndex = 0;

        for (uint i = 0; i < addresses.length; i++) {
            TokenInfo[] memory addressInfos = getTokenInfo(addresses[i], user);
            for (uint j = 0; j < addressInfos.length; j++) {
                infos[currentInfoIndex++] = addressInfos[j];
            }
        }

        return infos;
    }
}
