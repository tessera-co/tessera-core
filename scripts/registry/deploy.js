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
    const VaultRegistry = await ethers.getContractFactory("VaultRegistry", {
      libraries: { Create2ClonesWithImmutableArgs: clones.address }
    });
    const Metadata = await ethers.getContractFactory("Metadata");

    // Deploy contracts in necessary order
    const registry = await VaultRegistry.deploy();
    await registry.deployed();

    const implementation = await registry.fNFTImplementation();
    const ferc1155 = await registry.fNFT();

    const metadata = await Metadata.deploy(ferc1155);
    await metadata.deployed();

    // Log addresses of deployed contracts
    console.log("FERC1155 Proxy address:", ferc1155);
    console.log("FERC1155 Implementation address:", implementation);
    console.log("Metadata address:", metadata.address);
    console.log("VaultRegistry address:", registry.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
