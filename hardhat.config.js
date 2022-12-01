require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
// require('dotenv').config({ path: __dirname + '/.env' })

module.exports = {
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`${process.env.GOERLI_PRIVATE_KEY}`], chainId: 5, allowUnlimitedContractSize: true, blockGasLimit: 200000000429720,
    }
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  
  solidity: {
    compilers: [
      {
        version: "0.8.6",
        // settings: {
        //   optimizer: {
        //     enabled: true,
        //     runs: 200,
        //   },
        // },
      }, 
      {
        version: "0.6.6",
        settings: {},
      }, 
    ],
  }
}