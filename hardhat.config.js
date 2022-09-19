require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
// require("hardhat-gas-reporter");
// require("solidity-coverage");
// require('hardhat-docgen');
// require("@nomiclabs/hardhat-solhint");
const dotenv = require("dotenv");
dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  networks: {
    ropsten: {
      url: process.env.TEST_NET_API_KEY,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
    },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  
  solidity: {
    compilers: [
      {
        version: "0.8.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  }
};
