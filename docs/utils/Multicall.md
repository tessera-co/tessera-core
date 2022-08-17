# Solidity API

## Multicall

Utility contract that enables calling multiple local methods in a single call

### multicall

```solidity
function multicall(bytes[] _data) external returns (bytes[] results)
```

Allows multiple function calls within a contract that inherits from it

| Name | Type | Description |
| ---- | ---- | ----------- |
| _data | bytes[] | List of encoded function calls to make in this contract |

| Name | Type | Description |
| ---- | ---- | ----------- |
| results | bytes[] | List of return responses for each encoded call passed |

### _revertedWithReason

```solidity
function _revertedWithReason(bytes _response) internal pure
```

Handles function for revert responses

| Name | Type | Description |
| ---- | ---- | ----------- |
| _response | bytes | Reverted return response from a delegate call |

