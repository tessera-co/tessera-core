# Solidity API

## IVaultFactory

_Interface for VaultFactory contract_

### DeployVault

```solidity
event DeployVault(address _origin, address _deployer, address _owner, bytes32 _seed, bytes32 _salt, address _vault)
```

_Event log for deploying vault_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _origin | address | Address of transaction origin |
| _deployer | address | Address of sender |
| _owner | address | Address of vault owner |
| _seed | bytes32 | Value of seed |
| _salt | bytes32 | Value of salt |
| _vault | address | Address of deployed vault |

### deploy

```solidity
function deploy(bytes32 _merkleRoot, address[] _plugins, bytes4[] _selectors) external returns (address payable vault)
```

### deployFor

```solidity
function deployFor(bytes32 _merkleRoot, address _owner, address[] _plugins, bytes4[] _selectors) external returns (address payable vault)
```

### getNextAddress

```solidity
function getNextAddress(address _deployer, bytes32 _merkleRoot) external view returns (address vault)
```

### getNextSeed

```solidity
function getNextSeed(address _deployer) external view returns (bytes32)
```

### implementation

```solidity
function implementation() external view returns (address)
```

