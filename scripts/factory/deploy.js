const hre = require("hardhat");
const fs = require("fs");
const contractsDir = __dirname + "/../contracts";
const rinkebyFile = fs.readFileSync(contractsDir + "/rinkeby.json");
const contractAddr = JSON.parse(rinkebyFile);

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deployer address:", await deployer.getAddress());
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Get all contract factories
    const VaultFactory = await ethers.getContractFactory("VaultFactory", {
      libraries: { Create2ClonesWithImmutableArgs: clones.address }
    });

    // Deploy contracts in necessary order
    const factory = await VaultFactory.deploy();
    await factory.deployed();
    const vault = await factory.implementation();

    // Log addresses of deployed contracts
    console.log("Vault Implementation address:", vault);
    console.log("VaultFactory address:", factory.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
