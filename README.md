# Solidity Boilerplate

This boilerplate demonstrates an advanced Hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The boilerplate comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts. It also comes with a variety of other tools, preconfigured to work with the project code.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

## Project Structure

```
 |--contracts\      # All the smart contracts
    |--shared\      # All the common function libraries etc
 |--script\         # All the custom scripts for e.g writing deployment scripts
 |--shared\         # All the contract's constructor parameters
    |--inputs\      # It stores the files that contains values for constructor parameters to be given at the time of deployment.
    |--arguments\   # It stores the files that contains values for constructor parameter to be given at the time of verification (check verification section below)
 |--test\           # All test cases
```

# Contract verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```

- In the _shared/inputs_ folder you can put the files containing the inputs required for the deployment of the contracts.

- In the _shared/arguments_ folder you can put the files containing the arguments required for the verification of those contracts.

- To verify the contract using the arguments in the shared/arguments folder you can use this:

```shell
hh verify --constructor-args "path/to/arguments/file" --network <NETWORK> "<CONTRACT_ADDRESS>"
```
