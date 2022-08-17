const fs = require("fs");
const rinkebyFile = fs.readFileSync(__dirname + "/../contracts/rinkeby.json");
const contractAddr = JSON.parse(rinkebyFile);

async function main() {
    await hre.run("verify:verify", {
        address: contractAddr.Supply,
        constructorArguments: [contractAddr.VaultRegistry]
    });

    await hre.run("verify:verify", {
        address: contractAddr.Transfer,
        constructorArguments: []
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
