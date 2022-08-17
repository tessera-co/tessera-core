const hre = require("hardhat");
const fs = require("fs");
const contractsDir = __dirname + "/contracts";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deployer address:", await deployer.getAddress());
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Deploy library contracts first
    const ClonesWithImmutableArgs = await ethers.getContractFactory("Create2ClonesWithImmutableArgs");
    const clones = await ClonesWithImmutableArgs.deploy();
    await clones.deployed();

    // Get all contract factories
    const BaseVault = await ethers.getContractFactory("BaseVault");
    const Buyout = await ethers.getContractFactory("Buyout");
    const Metadata = await ethers.getContractFactory("Metadata");
    const Supply = await ethers.getContractFactory("Supply");
    const Transfer = await ethers.getContractFactory("Transfer");
    const VaultFactory = await ethers.getContractFactory("VaultFactory", {
      libraries: { Create2ClonesWithImmutableArgs: clones.address }
    });
    const VaultRegistry = await ethers.getContractFactory("VaultRegistry", {
      libraries: { Create2ClonesWithImmutableArgs: clones.address }
    });

    // Deploy contracts in necessary order
    const factory = await VaultFactory.deploy();
    await factory.deployed();
    const vault = await factory.implementation();

    const registry = await VaultRegistry.deploy();
    await registry.deployed();

    const implementation = await registry.fNFTImplementation();
    const ferc1155 = await registry.fNFT();
    const metadata = await Metadata.deploy(ferc1155);

    const supply = await Supply.deploy(registry.address);
    await supply.deployed();

    const transfer = await Transfer.deploy();
    await transfer.deployed();

    const buyout = await Buyout.deploy(registry.address, supply.address, transfer.address);
    await buyout.deployed();

    const baseVault = await BaseVault.deploy(registry.address, supply.address);
    await baseVault.deployed();

    // Log addresses of deployed contracts
    console.log("BaseVault address:", baseVault.address);
    console.log("Buyout address:", buyout.address);
    console.log("ClonesWithImmutableArgs address:", clones.address);
    console.log("FERC1155 Proxy address:", ferc1155);
    console.log("FERC1155 Implementation address:", implementation);
    console.log("Metadata address:", metadata.address);
    console.log("Supply address:", supply.address);
    console.log("Transfer address:", transfer.address);
    console.log("Vault Implementation address:", vault);
    console.log("VaultFactory address:", factory.address);
    console.log("VaultRegistry address:", registry.address);

    const contracts = {
        BaseVault: baseVault.address,
        Buyout: buyout.address,
        Clones: clones.address,
        FERC1155: ferc1155,
        Implementation: implementation,
        Metadata: metadata.address,
        Supply: supply.address,
        Transfer: transfer.address,
        Vault: vault,
        VaultFactory: factory.address,
        VaultRegistry: registry.address
    };

    saveAddress(contracts);
}

function saveAddress(contracts) {
    if (!fs.existsSync(contractsDir)) {
        fs.mkdirSync(contractsDir);
    }

    fs.writeFileSync(
        contractsDir + "/rinkeby.json",
        JSON.stringify({
            BaseVault: contracts["BaseVault"],
            Buyout: contracts["Buyout"],
            Clones: contracts["Clones"],
            FERC1155: contracts["FERC1155"],
            Implementation: contracts["Implementation"],
            Metadata: contracts["Metadata"],
            Supply: contracts["Supply"],
            Transfer: contracts["Transfer"],
            Vault: contracts["Vault"],
            VaultFactory: contracts["VaultFactory"],
            VaultRegistry: contracts["VaultRegistry"]
        }, undefined, 2)
    );
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
