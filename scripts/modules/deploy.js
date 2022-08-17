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
    const BaseVault = await ethers.getContractFactory("BaseVault");
    const Buyout = await ethers.getContractFactory("Buyout");

    // Deploy contracts in necessary order
    const buyout = await Buyout.deploy(contractAddr.VaultRegistry, contractAddr.Supply, contractAddr.Transfer);
    await buyout.deployed();

    const baseVault = await BaseVault.deploy(contractAddr.VaultRegistry, contractAddr.Supply);
    await baseVault.deployed();

    // Log addresses of deployed contracts
    console.log("BaseVault address:", baseVault.address);
    console.log("Buyout address:", buyout.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
