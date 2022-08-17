# Solidity API

## VaultRegistry

Registry contract for tracking all fractional vaults

### factory

```solidity
address factory
```

Address of VaultFactory contract

### fNFT

```solidity
address fNFT
```

Address of FERC1155 token contract

### fNFTImplementation

```solidity
address fNFTImplementation
```

Address of Implementation for FERC1155 token contract

### nextId

```solidity
mapping(address => uint256) nextId
```

Mapping of collection address to next token ID type

### vaultToToken

```solidity
mapping(address => struct VaultInfo) vaultToToken
```

Mapping of vault address to vault information

### constructor

```solidity
constructor() public
```

Initializes factory, implementation, and token contracts

### burn

```solidity
function burn(address _from, uint256 _value) external
```

Burns vault tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _from | address | Source address |
| _value | uint256 | Amount of tokens |

### create

```solidity
function create(bytes32 _merkleRoot, address[] _plugins, bytes4[] _selectors) external returns (address vault)
```

Creates a new vault with permissions and plugins

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | Hash of merkle root for vault permissions |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

| Name | Type | Description |
| ---- | ---- | ----------- |
| vault | address | Address of Proxy contract |

### createFor

```solidity
function createFor(bytes32 _merkleRoot, address _owner, address[] _plugins, bytes4[] _selectors) external returns (address vault)
```

Creates a new vault with permissions and plugins, and transfers ownership to a given owner

_This should only be done in limited cases i.e. if you're okay with a trusted individual(s)
having control over the vault. Ideally, execution would be locked behind a Multisig wallet._

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | Hash of merkle root for vault permissions |
| _owner | address | Address of the vault owner |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

| Name | Type | Description |
| ---- | ---- | ----------- |
| vault | address | Address of Proxy contract |

### createCollection

```solidity
function createCollection(bytes32 _merkleRoot, address[] _plugins, bytes4[] _selectors) external returns (address vault, address token)
```

Creates a new vault with permissions and plugins for the message sender

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | Hash of merkle root for vault permissions |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

| Name | Type | Description |
| ---- | ---- | ----------- |
| vault | address | Address of Proxy contract |
| token | address | Address of FERC1155 contract |

### createInCollection

```solidity
function createInCollection(bytes32 _merkleRoot, address _token, address[] _plugins, bytes4[] _selectors) external returns (address vault)
```

Creates a new vault with permissions and plugins for an existing collection

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | Hash of merkle root for vault permissions |
| _token | address | Address of FERC1155 contract |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

| Name | Type | Description |
| ---- | ---- | ----------- |
| vault | address | Address of Proxy contract |

### mint

```solidity
function mint(address _to, uint256 _value) external
```

Mints vault tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Target address |
| _value | uint256 | Amount of tokens |

### totalSupply

```solidity
function totalSupply(address _vault) external view returns (uint256)
```

Gets the total supply for a token and ID associated with a vault

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Total supply |

### uri

```solidity
function uri(address _vault) external view returns (string)
```

Gets the uri for a given token and ID associated with a vault

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | URI of token |

### createCollectionFor

```solidity
function createCollectionFor(bytes32 _merkleRoot, address _controller, address[] _plugins, bytes4[] _selectors) public returns (address vault, address token)
```

Creates a new vault with permissions and plugins for a given controller

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | Hash of merkle root for vault permissions |
| _controller | address | Address of token controller |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

| Name | Type | Description |
| ---- | ---- | ----------- |
| vault | address | Address of Proxy contract |
| token | address | Address of FERC1155 contract |

### _deployVault

```solidity
function _deployVault(bytes32 _merkleRoot, address _owner, address _token, address[] _plugins, bytes4[] _selectors) private returns (address vault)
```

_Deploys new vault for specified token, sets merkle root, and installs plugins_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | Hash of merkle root for vault permissions |
| _owner | address |  |
| _token | address | Address of FERC1155 contract |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

| Name | Type | Description |
| ---- | ---- | ----------- |
| vault | address | Address of Proxy contract |

