# Solidity API

## BaseVault

Protoform contract for vault deployments with a fixed supply and buyout mechanism

### registry

```solidity
address registry
```

Address of VaultRegistry contract

### constructor

```solidity
constructor(address _registry, address _supply) public
```

Initializes registry and supply contracts

| Name | Type | Description |
| ---- | ---- | ----------- |
| _registry | address | Address of the VaultRegistry contract |
| _supply | address | Address of the Supply target contract |

### deployVault

```solidity
function deployVault(uint256 _fractionSupply, address[] _modules, address[] _plugins, bytes4[] _selectors, bytes32[] _mintProof) external returns (address vault)
```

Deploys a new Vault and mints initial supply of fractions

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fractionSupply | uint256 | Number of NFT Fractions minted to control the vault |
| _modules | address[] | The list of modules to be installed on the vault |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |
| _mintProof | bytes32[] | List of proofs to execute a mint function |

### batchDepositERC20

```solidity
function batchDepositERC20(address _to, address[] _tokens, uint256[] _amounts) external
```

Transfers ERC-20 tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Target address |
| _tokens | address[] |  |
| _amounts | uint256[] |  |

### batchDepositERC721

```solidity
function batchDepositERC721(address _to, address[] _tokens, uint256[] _ids) external
```

Transfers ERC-721 tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Target address |
| _tokens | address[] |  |
| _ids | uint256[] |  |

### batchDepositERC1155

```solidity
function batchDepositERC1155(address _to, address[] _tokens, uint256[] _ids, uint256[] _amounts, bytes[] _datas) external
```

Transfers ERC-1155 tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Target address |
| _tokens | address[] |  |
| _ids | uint256[] |  |
| _amounts | uint256[] |  |
| _datas | bytes[] |  |

### generateMerkleTree

```solidity
function generateMerkleTree(address[] _modules) public view returns (bytes32[] hashes)
```

Generates a merkle tree from the hashed permission lists of the given modules

| Name | Type | Description |
| ---- | ---- | ----------- |
| _modules | address[] | List of module contracts |

| Name | Type | Description |
| ---- | ---- | ----------- |
| hashes | bytes32[] | A combined list of leaf nodes |

