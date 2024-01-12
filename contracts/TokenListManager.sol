// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITokenListManager.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract TokenListManager is ITokenListManager, AccessControl {

    // Utilize EnumerableSet for efficient set operations.
    using EnumerableSet for EnumerableSet.AddressSet;
    // Use ERC165Checker to detect supported interfaces
    using ERC165Checker for address;

    // Define roles for administrative control and user access.
    bytes32 public constant TOKEN_MANAGER_ROLE = keccak256("TOKEN_MANAGER_ROLE");

    // Create whitelist for ERC20, ERC721 and ERC1155 token types
    EnumerableSet.AddressSet private whitelistedERC20;
    EnumerableSet.AddressSet private whitelistedERC721;
    EnumerableSet.AddressSet private whitelistedERC1155;
    // Create blacklist for ERC20, ERC721 and ERC1155 token types
    EnumerableSet.AddressSet private blacklistedERC20;
    EnumerableSet.AddressSet private blacklistedERC721;
    EnumerableSet.AddressSet private blacklistedERC1155;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TOKEN_MANAGER_ROLE, msg.sender);
    }

    // Add tokens to whitelist, only accessible by admin
    function addTokens(address[] calldata tokens) external onlyRole(TOKEN_MANAGER_ROLE) {

        for (uint i = 0; i < tokens.length; i++) {
            // According to the token type, add it to the whitelist and check whether it is in the blacklist
            if (tokens[i].supportsInterface(type(IERC721).interfaceId)) {
                require(!blacklistedERC721.contains(tokens[i]), "Token is in the blacklist");
                whitelistedERC721.add(tokens[i]);
            } else if (tokens[i].supportsInterface(type(IERC1155).interfaceId)) {
                require(!blacklistedERC1155.contains(tokens[i]), "Token is in the blacklist");
                whitelistedERC1155.add(tokens[i]);
            } else {
                // If it is not ERC-721 or ERC-1155, mark it as ERC-20
                require(!blacklistedERC20.contains(tokens[i]), "Token is in the blacklist");
                whitelistedERC20.add(tokens[i]);
            }
        }
    }

    // Remove tokens from whitelist, only accessible by admin
    function removeTokens(address[] calldata tokens) external onlyRole(TOKEN_MANAGER_ROLE) {

        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].supportsInterface(type(IERC721).interfaceId)) {
                whitelistedERC721.remove(tokens[i]);
            } else if (tokens[i].supportsInterface(type(IERC1155).interfaceId)) {
                whitelistedERC1155.remove(tokens[i]);
            } else {
                whitelistedERC20.remove(tokens[i]);
            }
        }
    }

    // Add tokens to blacklist, only accessible by admin
    function addBlacklistedTokens(address[] calldata tokens) external onlyRole(TOKEN_MANAGER_ROLE) {

        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].supportsInterface(type(IERC721).interfaceId)) {
                require(!whitelistedERC721.contains(tokens[i]), "Token is in the whitelist");
                blacklistedERC721.add(tokens[i]);
            } else if (tokens[i].supportsInterface(type(IERC1155).interfaceId)) {
                require(!whitelistedERC1155.contains(tokens[i]), "Token is in the whitelist");
                blacklistedERC1155.add(tokens[i]);
            } else {
                require(!whitelistedERC20.contains(tokens[i]), "Token is in the whitelist");
                blacklistedERC20.add(tokens[i]);
            }
        }
    }

    // Remove tokens from blacklist, only accessible by admin
    function removeBlacklistedTokens(address[] calldata tokens) external onlyRole(TOKEN_MANAGER_ROLE) {

        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].supportsInterface(type(IERC721).interfaceId)) {
                blacklistedERC721.remove(tokens[i]);
            } else if (tokens[i].supportsInterface(type(IERC1155).interfaceId)) {
                blacklistedERC1155.remove(tokens[i]);
            } else {
                blacklistedERC20.remove(tokens[i]);
            }
        }
    }

    // Get the token address list from EnumerableSet, mainly used to implement paging function
    function getTokensFromSet(EnumerableSet.AddressSet storage set, uint256 offset, uint256 limit) 
    internal view returns (address[] memory tokens) {
    
        uint256 total = set.length();
        uint256 numItems = (offset + limit > total) ? total - offset : limit;
        tokens = new address[](numItems);

        for (uint256 i = 0; i < numItems; i++) {
            tokens[i] = set.at(offset + i);
        }
    }

    // Get the list of tokens in the whitelist
    function getWhitelistedTokens(TokenType tokenType, uint256 offset, uint256 limit) 
    external view override returns (address[] memory tokens) {
        if (tokenType == TokenType.ERC20) {
            tokens = getTokensFromSet(whitelistedERC20, offset, limit);
        } else if (tokenType == TokenType.ERC721) {
            tokens = getTokensFromSet(whitelistedERC721, offset, limit);
        } else if (tokenType == TokenType.ERC1155) {
            tokens = getTokensFromSet(whitelistedERC1155, offset, limit);
        }
    }

    // Get the list of tokens in the blacklist
    function getBlacklistedTokens(TokenType tokenType, uint256 offset, uint256 limit)
    external view override returns (address[] memory tokens) {
        if (tokenType == TokenType.ERC20) {
            tokens = getTokensFromSet(blacklistedERC20, offset, limit);
        } else if (tokenType == TokenType.ERC721) {
            tokens = getTokensFromSet(blacklistedERC721, offset, limit);
        } else if (tokenType == TokenType.ERC1155) {
            tokens = getTokensFromSet(blacklistedERC1155, offset, limit);
        }
    }

    // Check if the token is in the whitelist
    function isWhitelisted(address token) public view returns (bool) {
        if (token.supportsInterface(type(IERC721).interfaceId)) {
            return whitelistedERC721.contains(token);
        } else if (token.supportsInterface(type(IERC1155).interfaceId)) {
            return whitelistedERC1155.contains(token);
        } else {
            return whitelistedERC20.contains(token);
        }
    }

    // Check if the token is in the blacklist
    function isBlacklisted(address token) public view returns (bool) {
        if (token.supportsInterface(type(IERC721).interfaceId)) {
            return blacklistedERC721.contains(token);
        } else if (token.supportsInterface(type(IERC1155).interfaceId)) {
            return blacklistedERC1155.contains(token);
        } else {
            return blacklistedERC20.contains(token);
        }
    }
}
