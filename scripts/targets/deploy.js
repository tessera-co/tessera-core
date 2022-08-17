const hre = require("hardhat")
const fs = require("fs");
const contractsDir = __dirname + "/../contracts";
const rinkebyFile = fs.readFileSync(contractsDir + "/rinkeby.json");
const contractAddr = JSON.parse(rinkebyFile);

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deployer address:", await deployer.getAddress());
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Get all contract factories
    const Supply = await ethers.getContractFactory("Supply");
    const Transfer = await ethers.getContractFactory("Transfer");

    // Deploy contracts in necessary order
    const supply = await Supply.deploy(contractAddr.VaultRegistry);
    await supply.deployed();

    const transfer = await Transfer.deploy();
    await transfer.deployed();

    // Log addresses of deployed contracts
    console.log("Supply address:", supply.address);
    console.log("Transfer address:", transfer.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
