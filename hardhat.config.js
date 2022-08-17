require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("solidity-docgen");

module.exports = {
    solidity: {
        version: "0.8.13",
        settings: {
            optimizer: {
                enabled: true,
                runs: 15000
            }
        }
    },
    paths: {
        sources: "./src",
        artifacts: "./artifacts",
        cache: "./hh-cache"
    },
    docgen: {
      pages: 'files',
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY
    },
    networks: {
        hardhat: {
            chainId: 1337,
            blockGasLimit: 30_000_000
        },
        rinkeby: {
            url: "https://eth-rinkeby.alchemyapi.io/v2/" + `${process.env.ALCHEMY_API_KEY}`,
            accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`]
        },
        mainnet: {
            url: "https://eth-mainnet.alchemyapi.io/v2/" + `${process.env.ALCHEMY_API_KEY}`,
            accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`]
        }
    }
};
