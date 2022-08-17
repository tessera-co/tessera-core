const fs = require("fs");
const rinkebyFile = fs.readFileSync(__dirname + "/contracts/rinkeby.json");
const contractAddr = JSON.parse(rinkebyFile);

async function main() {
    await hre.run("verify:verify", {
        address: contractAddr.BaseVault,
        constructorArguments: [
            contractAddr.VaultRegistry,
            contractAddr.Supply
        ],
    });

    await hre.run("verify:verify", {
        address: contractAddr.Buyout,
        constructorArguments: [
            contractAddr.VaultRegistry,
            contractAddr.Supply,
            contractAddr.Transfer
        ],
    });

    await hre.run("verify:verify", {
        address: contractAddr.FERC1155,
        constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: contractAddr.Implementation,
        constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: contractAddr.Metadata,
        constructorArguments: [contractAddr.FERC1155],
    });

    await hre.run("verify:verify", {
        address: contractAddr.Supply,
        constructorArguments: [contractAddr.VaultRegistry],
    });

    await hre.run("verify:verify", {
        address: contractAddr.Transfer,
        constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: contractAddr.Vault,
        constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: contractAddr.VaultFactory,
        constructorArguments: [],
        libraries: {
            Create2ClonesWithImmutableArgs: contractAddr.Clones
        }
    });

    await hre.run("verify:verify", {
        address: contractAddr.VaultRegistry,
        constructorArguments: [],
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
