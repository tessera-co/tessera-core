# Modular Fractional

[![Gitbook](https://img.shields.io/badge/docs-%F0%9F%93%84-blue)](https://docs.fractional.art/fractional-v2-1)

Fractional is a decentralized protocol that allows for shared ownership and governance of NFTs. When an NFT is fractionalized, the newly minted tokens function as normal ERC-1155 tokens which govern the non-custodial Vault containing the NFT(s).

The Fractional v2 Protocol is designed around the concept of [Hyperstructures](https://jacob.energy/hyperstructures.html), which are _crypto protocols that can run for free and forever, without maintenance, interruption or intermediaries_.

### Vaults

> The home of all items on Fractional

Vaults are a slightly modified implementation of [PRBProxy](https://github.com/paulrberg/prb-proxy) which is a basic and non-upgradeable proxy contract. Think of a Vault as a smart wallet that enables the execution of arbitrary smart contract calls in a single transaction. Generally, the calls a Vault can make are disabled and must be explicitly allowed through permissions. The vault is intentionally left unopinionated and extremely flexible for experimentation in the future.

### Permissions

> Authorize transactions performed on a vault

A permission is a combination of a _Module_ contract, _Target_ contract, and specific function _Selector_ in a target contract that can be executed by the vault. A group of permissions creates the set of functions that are callable by the Vault in order to carry out its specific use case. Each permission is then hashed and used as a leaf node to generate a merkle tree, where the merkle root of the tree is stored on the vault itself. Whenever a transaction is executed on a vault, a merkle proof is used to verify legitimacy of the leaf node (Permission) and the merkle root.

### Modules

> Make vaults do cool stuff

Modules are the bread and butter of what makes Fractional unique. At Vault creation, modules are added to permissions for the vault. Each module should have specific goals it plans to accomplish. Some general examples are Buyouts, Inflation, Migration, and Renting. If a vault wants to update the set of modules enabled, then it must have the migration module enabled and go through the migration process.
In general, it is highly recommended for vaults to have a module that enables items to be removed from vaults. Without this, all items inside of a vault will be stuck forever.

### Targets

> Execute vault transactions

Targets are stateless script-like contracts for executing transactions by the Vault on-behalf of a user. Only functions of a target contract that are initially set as enabled permissions for a vault can be executed by a vault.

### Plugins

> Functions added directly onto a vault

Plugins are similar to targets in that they are stateless script-like contracts. The main difference is that the functions from plugin contracts get installed on Vaults and are executed as if they were on the Vault itself via the fallback function.

## Setup

> Required **> node 12**

> On windows use WSL or the Docker image

#### Install Foundry on Mac/Unix:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

#### Install Foundry with Docker:

```
docker pull ghcr.io/foundry-rs/foundry:latest
```

#### Install node packages:

```
npm ci
```

#### Install gitmodule dependencies:

```
make deps
```

#### Generate blacksmith user proxies:

```
make users
```

#### Compile contracts:

```
make build
```

#### Run tests:

```
make test
```

#### Run gas report:

```
make report
```

#### Run linter:

```
npm run lint
```

#### Environment variables:

```
ALCHEMY_API_KEY=
DEPLOYER_PRIVATE_KEY=
ETHERSCAN_API_KEY=
```

#### [Generate snapshot](https://book.getfoundry.sh/forge/gas-snapshots.html) of gas usage:

```
forge snapshot
```

#### [Generate documents](https://github.com/OpenZeppelin/solidity-docgen) from NatSpec comments:

```
npx hardhat docgen
```

#### [Generate merkle tree](https://github.com/miguelmota/merkletreejs) from Vault permissions:

```
npx hardhat run scripts/merkle/permission.js
```

#### Deploy all contracts to testnet:

```
npx hardhat run scripts/deploy.js --network rinkeby
```

#### Verify all contracts on testnet:

```
npx hardhat run scripts/verify.js --network rinkeby
```

## Rinkeby Contracts

| Name            | Type      | Address                                                                                                                       |
| --------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `BaseVault`     | Protoform | [0xec194Dee666725E512DBe2bf40306C7C9BCD4651](https://rinkeby.etherscan.io/address/0xec194Dee666725E512DBe2bf40306C7C9BCD4651) |
| `Buyout`        | Module    | [0x7003c79786f5Af5079699BA77DE9CB04cc569fD4](https://rinkeby.etherscan.io/address/0x7003c79786f5Af5079699BA77DE9CB04cc569fD4) |
| `FERC1155`      | Proxy     | [0x88a8c1e700d51746de0d3bd8ca0aef1912628656](https://rinkeby.etherscan.io/address/0x88a8c1e700d51746de0d3bd8ca0aef1912628656) |
| `FERC1155`      | Implementation | [0xD09FE23b7B5a2E7a3BAf9079D9a1cfC9E0209AD0](https://rinkeby.etherscan.io/address/0xD09FE23b7B5a2E7a3BAf9079D9a1cfC9E0209AD0) |
| `Metadata`      | Utility   | [0x6e2e12043B63949BF82FCE7b455ac53cbC3eaD24](https://rinkeby.etherscan.io/address/0x6e2e12043B63949BF82FCE7b455ac53cbC3eaD24) |
| `Supply`        | Target    | [0x88B8b0D1047caDD2B28AaEdf2fE2B863fe8885C2](https://rinkeby.etherscan.io/address/0x88B8b0D1047caDD2B28AaEdf2fE2B863fe8885C2) |
| `Transfer`      | Target    | [0x4a92225796d01840AF1e07b8D872A046d0F08Edc](https://rinkeby.etherscan.io/address/0x4a92225796d01840AF1e07b8D872A046d0F08Edc) |
| `Vault`         | Implementation  | [0x63625DA7E523e716B1E317493Acd2b8d79e4230A](https://rinkeby.etherscan.io/address/0x63625DA7E523e716B1E317493Acd2b8d79e4230A) |
| `VaultFactory`  | Factory   | [0x9BA1Ec3f27FA46c42ba49ba76Bd082dD6DAFAA20](https://rinkeby.etherscan.io/address/0x9BA1Ec3f27FA46c42ba49ba76Bd082dD6DAFAA20) |
| `VaultRegistry` | Registry  | [0x2580E23D6Bc9E23F5EF55563b1e3E5AFe2711689](https://rinkeby.etherscan.io/address/0x2580E23D6Bc9E23F5EF55563b1e3E5AFe2711689) |

## Resources

| Name                                                                                                     | Description                                                                              |
| -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [Blacksmith](https://github.com/pbshgthm/blacksmith)                                                     | Full-fledged contract generator to create User contracts for testing purposes            |
| [ClonesWithImmutableArgs](https://github.com/wighawag/clones-with-immutable-args)                        | Enables creating clone contracts with immutable arguments                                |
| [Forge Standard Library](https://github.com/foundry-rs/forge-std)                                        | Leverages forge's cheatcodes to make writing tests easier and faster in Foundry          |
| [Foundry](https://github.com/foundry-rs/foundry)                                                         | Framework for Ethereum application development                                           |
| [Hardhat](https://github.com/NomicFoundation/hardhat)                                                    | Development environment for deploying and interacting with smart contracts               |
| [Multicall (Uniswap v3)](https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicall.sol) | Enables calling multiple methods in a single call to the contract                        |
| [Murky](https://github.com/dmfxyz/murky)                                                                 | Generates merkle roots and verifies proofs in Solidity                                   |
| [NatSpec Format](https://docs.soliditylang.org/en/v0.8.13/natspec-format.html)                           | A special form of comments to provide rich documentation                                 |
| [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)                                   | Library of community-vetted code for secure smart contract development                   |
| [PRBProxy](https://github.com/paulrberg/prb-proxy)                                                       | Proxy contract to compose Ethereum transactions on behalf of the owner                   |
| [Seaport](https://github.com/ProjectOpenSea/seaport/blob/main/contracts/lib/TokenTransferrer.sol)        | Library for performing optimized token transfers from OpenSea's new marketplace protocol |
| [Solidity Style Guide](https://github.com/ethereum/solidity/blob/develop/docs/style-guide.rst)           | Standard coding conventions for writing Solidity code                                    |
| [Solmate](https://github.com/Rari-Capital/solmate)                                                       | Building blocks for smart contract development                                           |
