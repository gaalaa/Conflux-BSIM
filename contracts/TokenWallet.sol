// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import ''

contract MyTokenWallet is BSIMWallet {

    // 实现getTokenBalance方法
    function getTokenBalance(address wallet, address token) external view override returns (uint256) {
        IERC20 tokenContract = IERC20(token);
        return tokenContract.balanceOf(wallet);
    }

    // 实现getNFTDetails方法
    function getNFTDetails(address wallet, address nftAddress, uint256 tokenId) external view override returns (NFTDetails memory) {
        IERC721 nftContract = IERC721(nftAddress);
        string memory tokenURI = nftContract.tokenURI(tokenId);

        // 解析tokenURI以获取NFT的详细信息

        return NFTDetails({
            nftAddress: nftAddress,
            tokenId: tokenId,
            imageURL: "", // 假设从tokenURI解析得到的图像URL
            description: "" // 假设从tokenURI解析得到的描述
        });
    }

    //实现detectTokenTypes方法
    function detectTokenTypes(address wallet) external view override returns (TokenType[] memory) {
        // 初始化一个TokenType数组
        TokenType[] memory tokens = new TokenType[](0xc0ec75c25ec201885a791fd8d39bf8ce96e1c566.length);

        for (uint i = 0; i < 0xc0ec75c25ec201885a791fd8d39bf8ce96e1c566.length; i++) {
            // 对于每个已知的代币地址，检查钱包中是否有余额
            // 对于ERC-20代币:
            IERC20 token = IERC20(0xc0ec75c25ec201885a791fd8d39bf8ce96e1c566[i]);
            if (token.balanceOf(wallet) > 0) {
                // 如果钱包中有余额，添加到数组中
                tokens[i] = TokenType({
                    tokenAddress: 0xc0ec75c25ec201885a791fd8d39bf8ce96e1c566[i],
                    tokenType: "ERC-20",
                    name: token.name(),
                    symbol: token.symbol()
                });
            }
        }

        return tokens;
    }
}
