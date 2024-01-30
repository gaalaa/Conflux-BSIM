# Conflux-BSIM

Description:
1. Solidity Version: 0.8.20
2. 

TokenListManager: This contract is responsible for managing the whitelist and blacklist of ERC20, ERC721, and ERC1155 tokens. It allows users with the TOKEN_MANAGER_ROLE role to add or remove specific token addresses. Use EnumerableSet to manage address collections and use ERC165Checker to detect whether the token supports a specific interface.

Wallet: This contract provides functions related to user wallets, such as obtaining paginated token information, checking which tokens the user owns, obtaining a list of token addresses, etc. It relies on the TokenListManager contract to obtain the token addresses in the whitelist, and queries and returns the token information held by the user based on these addresses.
