require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
// require('dotenv').config({ path: __dirname + '/.env' })

// const dotenv = require("dotenv");
// dotenv.config();
// const { ALCHEMY_API_KEY, GOERLI_PRIVATE_KEY } = process.env
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();
//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

module.exports = {
  networks: {
    goerli: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`${process.env.GOERLI_PRIVATE_KEY}`], 
    }
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
    ],
  }
}