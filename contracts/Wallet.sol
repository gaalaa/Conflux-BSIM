// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/ICRC1155Metadata.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/ICRC1155Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
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
    function getTokenInfo(address tokenAddress, address user) private view returns (TokenInfo memory) {
        TokenType tokenType = getTokenType(tokenAddress);
    
        // Default empty struct. Used when the token balance is zero or token type is unsupported.
        TokenInfo memory info;

        if (tokenType == TokenType.ERC20) {
            IERC20Metadata token = IERC20Metadata(tokenAddress);
            uint256 balance = token.balanceOf(user);
            if (balance > 0) {
                info = TokenInfo({
                    tokenAddress: tokenAddress,
                    balance: balance,
                    name: token.name(),
                    symbol: token.symbol(),
                    decimals: token.decimals()
                });
            }
        } else if (tokenType == TokenType.ERC721) {
            IERC721Metadata token = IERC721Metadata(tokenAddress);
            uint256 balance = token.balanceOf(user);
            if (balance > 0) {
                info = TokenInfo({
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
                info = TokenInfo({
                    tokenAddress: tokenAddress,
                    balance: tokenCount, // Count of distinct token IDs
                    name: tokenMetadata.name(),   // Fetching name from ICRC1155Metadata
                    symbol: tokenMetadata.symbol(), // Fetching symbol from ICRC1155Metadata
                    decimals: 0 // Set decimals to 0 for NFTs
                });
            }
        }

        return info;
    }
    
    // Public function to get paginated token information along with the total count
    function getPaginatedTokenInfo(TokenType tokenType, address user, uint start, uint limit)
    external view override returns (PaginatedTokenInfo memory) {
        // Fetch a large set of whitelisted tokens from the TokenListManager based on the token type
        uint256 largeLimit = type(uint256).max;
        address[] memory potentialTokenAddresses = tokenListManager.getWhitelistedTokens(tokenType, 0, largeLimit);

        // Temporary array to store token information
        TokenInfo[] memory tempInfos = new TokenInfo[](potentialTokenAddresses.length);
        uint256 totalInfosCount = 0;

        // Filter out tokens with non-zero balance
        for (uint256 i = 0; i < potentialTokenAddresses.length; i++) {
            TokenInfo memory info = getTokenInfo(potentialTokenAddresses[i], user);
            if (info.balance > 0) {
                tempInfos[totalInfosCount++] = info;
            }
        }

        // Determine the size of the paginated result
        uint256 paginatedSize = Math.min(totalInfosCount, limit);
        PaginatedTokenInfo memory result;
        result.tokens = new TokenInfo[](paginatedSize);
        result.total = totalInfosCount;  // Total number of tokens with non-zero balance

        // Fill in the paginated token information
        uint256 endIndex = Math.min(start + paginatedSize, totalInfosCount);
        for (uint256 i = start; i < endIndex; i++) {
            result.tokens[i - start] = tempInfos[i];
        }

        return result;
    }

    // Public function to get token information for a list of addresses.
    // Fetching token data across multiple addresses at once.
    function getTokenInfoForAddresses(address[] calldata addresses, address user) 
    external view returns (TokenInfo[] memory) {
        // Array to store results. Its size is the same as the input addresses array.
        TokenInfo[] memory infos = new TokenInfo[](addresses.length);
        uint256 count = 0;

        // Iterate over each address and get token info
        for (uint256 i = 0; i < addresses.length; i++) {
            TokenInfo memory info = getTokenInfo(addresses[i], user);
            if (info.balance > 0) {
                infos[count++] = info;
            }
        }

        // Create a new array to return only filled elements
        TokenInfo[] memory resultInfos = new TokenInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            resultInfos[i] = infos[i];
        }

        return resultInfos;
    }

}
