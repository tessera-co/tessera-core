# Solidity API

## ITransfer

_Interface for Transfer target contract_

### BadReturnValueFromERC20OnTransfer

```solidity
error BadReturnValueFromERC20OnTransfer(address _token, address _from, address _to, uint256 _amount)
```

_Emitted when an ERC-20 token transfer returns a falsey value_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | The token for which the ERC20 transfer was attempted |
| _from | address | The source of the attempted ERC20 transfer |
| _to | address | The recipient of the attempted ERC20 transfer |
| _amount | uint256 | The amount for the attempted ERC20 transfer |

### ERC1155BatchTransferGenericFailure

```solidity
error ERC1155BatchTransferGenericFailure(address _token, address _from, address _to, uint256[] _identifiers, uint256[] _amounts)
```

_Emitted when a batch ERC-1155 token transfer reverts_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | The token for which the transfer was attempted |
| _from | address | The source of the attempted transfer |
| _to | address | The recipient of the attempted transfer |
| _identifiers | uint256[] | The identifiers for the attempted transfer |
| _amounts | uint256[] | The amounts for the attempted transfer |

### InvalidERC721TransferAmount

```solidity
error InvalidERC721TransferAmount()
```

_Emitted when an ERC-721 transfer with amount other than one is attempted_

### MissingItemAmount

```solidity
error MissingItemAmount()
```

_Emitted when attempting to fulfill an order where an item has an amount of zero_

### NoContract

```solidity
error NoContract(address _account)
```

_Emitted when an account being called as an assumed contract does not have code and returns no data_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _account | address | The account that should contain code |

### TokenTransferGenericFailure

```solidity
error TokenTransferGenericFailure(address _token, address _from, address _to, uint256 _identifier, uint256 _amount)
```

_Emitted when an ERC-20, ERC-721, or ERC-1155 token transfer fails_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | The token for which the transfer was attempted |
| _from | address | The source of the attempted transfer |
| _to | address | The recipient of the attempted transfer |
| _identifier | uint256 | The identifier for the attempted transfer |
| _amount | uint256 | The amount for the attempted transfer |

### ERC20Transfer

```solidity
function ERC20Transfer(address _token, address _to, uint256 _value) external
```

### ERC721TransferFrom

```solidity
function ERC721TransferFrom(address _token, address _from, address _to, uint256 _tokenId) external
```

### ERC1155TransferFrom

```solidity
function ERC1155TransferFrom(address _token, address _from, address _to, uint256 _id, uint256 _value) external
```

### ERC1155BatchTransferFrom

```solidity
function ERC1155BatchTransferFrom(address _token, address _from, address _to, uint256[] _ids, uint256[] _values) external
```

