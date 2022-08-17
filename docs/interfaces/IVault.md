# Solidity API

## IVault

_Interface for Vault proxy contract_

### ExecutionReverted

```solidity
error ExecutionReverted()
```

_Emitted when execution reverted with no reason_

### Initialized

```solidity
error Initialized(address _owner, address _newOwner, uint256 _nonce)
```

_Emitted when ownership of the proxy has been renounced_

### MethodNotFound

```solidity
error MethodNotFound()
```

_Emitted when there is no implementation stored in methods for a function signature_

### ArrayMismatch

```solidity
error ArrayMismatch(uint256 _pluginsLength, uint256 _selectorsLength)
```

_Emitted when length of input arrays don't match_

### InvalidSelector

```solidity
error InvalidSelector(bytes4 _selector)
```

_Emitted when a plugin selector would overwrite an existing plugin_

### NotAuthorized

```solidity
error NotAuthorized(address _caller, address _target, bytes4 _selector)
```

_Emitted when the caller is not the owner_

### NotOwner

```solidity
error NotOwner(address _owner, address _caller)
```

_Emitted when the caller is not the owner_

### OwnerChanged

```solidity
error OwnerChanged(address _originalOwner, address _newOwner)
```

_Emitted when the owner is changed during the DELEGATECALL_

### TargetInvalid

```solidity
error TargetInvalid(address _target)
```

_Emitted when passing an EOA or an undeployed contract as the target_

### Execute

```solidity
event Execute(address _target, bytes _data, bytes _response)
```

_Event log for executing transactions_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _target | address | Address of target contract |
| _data | bytes | Transaction data being executed |
| _response | bytes | Return data of delegatecall |

### UpdatedPlugins

```solidity
event UpdatedPlugins(bytes4[] _selectors, address[] _plugins)
```

_Event log for installing plugins_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _selectors | bytes4[] | List of function selectors |
| _plugins | address[] | List of plugin contracts |

### execute

```solidity
function execute(address _target, bytes _data, bytes32[] _proof) external payable returns (bool success, bytes response)
```

### setPlugins

```solidity
function setPlugins(address[] _plugins, bytes4[] _selectors) external
```

### methods

```solidity
function methods(bytes4) external view returns (address)
```

### MERKLE_ROOT

```solidity
function MERKLE_ROOT() external view returns (bytes32)
```

### OWNER

```solidity
function OWNER() external view returns (address)
```

### FACTORY

```solidity
function FACTORY() external view returns (address)
```

