/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

module.exports = {  
  networks:{
    rinkeby:{
      url:`https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts:[`${process.env.RINKEBY_PRIVATE_KEY}`], 
    },
    ropsten:{
      url:`https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts:[`${process.env.ROPSTEN_PRIVATE_KEY}`],       
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  
  solidity: {
        compilers: [
          {
            version: "0.6.6",
            settings: {
              optimizer: {
                enabled: true,
                runs: 200,
              },
            },
          },
          {
            version: "0.5.16",
            settings: {
              optimizer: {
                enabled: true,
                runs: 200,
              },
            },
          },
        ],   
}};
