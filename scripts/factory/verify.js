const fs = require("fs");
const rinkebyFile = fs.readFileSync(__dirname + "/../contracts/rinkeby.json");
const contractAddr = JSON.parse(rinkebyFile);

async function main() {
    await hre.run("verify:verify", {
        address: contractAddr.VaultFactory,
        constructorArguments: [],
        libraries: {
            Create2ClonesWithImmutableArgs: contractAddr.Clones
        }
    });

    await hre.run("verify:verify", {
        address: contractAddr.Vault,
        constructorArguments: [],
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
