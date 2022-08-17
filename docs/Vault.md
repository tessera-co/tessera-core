# Solidity API

## Vault

Proxy contract for storing fractionalized assets

### MIN_GAS_RESERVE

```solidity
uint256 MIN_GAS_RESERVE
```

_Minimum reserve of gas units_

### FALLBACK_SELECTOR

```solidity
bytes4 FALLBACK_SELECTOR
```

### MERKLE_ROOT_POSITION

```solidity
uint256 MERKLE_ROOT_POSITION
```

### OWNER_POSITION

```solidity
uint256 OWNER_POSITION
```

### FACTORY_POSITION

```solidity
uint256 FACTORY_POSITION
```

### methods

```solidity
mapping(bytes4 => address) methods
```

Mapping of function selector to plugin address

### receive

```solidity
receive() external payable
```

_Callback for receiving Ether when the calldata is empty_

### fallback

```solidity
fallback(bytes _data) external payable returns (bytes response)
```

_Callback for handling plugin transactions_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _data | bytes | Transaction data |

| Name | Type | Description |
| ---- | ---- | ----------- |
| response | bytes | Return data from executing plugin |

### execute

```solidity
function execute(address _target, bytes _data, bytes32[] _proof) external payable returns (bool success, bytes response)
```

Executes vault transactions through delegatecall

| Name | Type | Description |
| ---- | ---- | ----------- |
| _target | address | Target address |
| _data | bytes | Transaction data |
| _proof | bytes32[] | Merkle proof of permission hash |

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | Result status of delegatecall |
| response | bytes | Return data of delegatecall |

### setPlugins

```solidity
function setPlugins(address[] _plugins, bytes4[] _selectors) external
```

Installs plugin by setting function selector to contract address

| Name | Type | Description |
| ---- | ---- | ----------- |
| _plugins | address[] | Addresses of plugin contracts |
| _selectors | bytes4[] | List of function selectors |

### MERKLE_ROOT

```solidity
function MERKLE_ROOT() public pure returns (bytes32)
```

Getter for merkle root stored as an immutable argument

### OWNER

```solidity
function OWNER() public pure returns (address)
```

Getter for owner of vault

### FACTORY

```solidity
function FACTORY() public pure returns (address)
```

Getter for factory of vault

### _execute

```solidity
function _execute(address _target, bytes _data) internal returns (bool success, bytes response)
```

Executes plugin transactions through delegatecall

| Name | Type | Description |
| ---- | ---- | ----------- |
| _target | address | Target address |
| _data | bytes | Transaction data |

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | Result status of delegatecall |
| response | bytes | Return data of delegatecall |

### _revertedWithReason

```solidity
function _revertedWithReason(bytes _response) internal pure
```

Reverts transaction with reason

| Name | Type | Description |
| ---- | ---- | ----------- |
| _response | bytes | Unsucessful return response of the delegate call |

