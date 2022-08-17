# Solidity API

## Permission

```solidity
struct Permission {
  address module;
  address target;
  bytes4 selector;
}
```

## VaultInfo

```solidity
struct VaultInfo {
  address token;
  uint256 id;
}
```

## IVaultRegistry

_Interface for VaultRegistry contract_

### InvalidController

```solidity
error InvalidController(address _controller, address _sender)
```

_Emitted when the caller is not the controller_

### UnregisteredVault

```solidity
error UnregisteredVault(address _sender)
```

_Emitted when the caller is not a registered vault_

### VaultDeployed

```solidity
event VaultDeployed(address _vault, address _token, uint256 _id)
```

_Event log for deploying vault_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _token | address | Address of the token |
| _id | uint256 | Id of the token |

### burn

```solidity
function burn(address _from, uint256 _value) external
```

### create

```solidity
function create(bytes32 _merkleRoot, address[] _plugins, bytes4[] _selectors) external returns (address vault)
```

### createCollection

```solidity
function createCollection(bytes32 _merkleRoot, address[] _plugins, bytes4[] _selectors) external returns (address vault, address token)
```

### createCollectionFor

```solidity
function createCollectionFor(bytes32 _merkleRoot, address _controller, address[] _plugins, bytes4[] _selectors) external returns (address vault, address token)
```

### createFor

```solidity
function createFor(bytes32 _merkleRoot, address _owner, address[] _plugins, bytes4[] _selectors) external returns (address vault)
```

### createInCollection

```solidity
function createInCollection(bytes32 _merkleRoot, address _token, address[] _plugins, bytes4[] _selectors) external returns (address vault)
```

### factory

```solidity
function factory() external view returns (address)
```

### fNFT

```solidity
function fNFT() external view returns (address)
```

### fNFTImplementation

```solidity
function fNFTImplementation() external view returns (address)
```

### mint

```solidity
function mint(address _to, uint256 _value) external
```

### nextId

```solidity
function nextId(address) external view returns (uint256)
```

### totalSupply

```solidity
function totalSupply(address _vault) external view returns (uint256)
```

### uri

```solidity
function uri(address _vault) external view returns (string)
```

### vaultToToken

```solidity
function vaultToToken(address) external view returns (address token, uint256 id)
```

