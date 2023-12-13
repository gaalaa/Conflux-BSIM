require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    espaceTestnet: {
      url: "https://evm.confluxrpc.com",
      accounts: ["YOUR_PRIVATE_KEY"],
    },
    // 其他网络配置
  },
};
