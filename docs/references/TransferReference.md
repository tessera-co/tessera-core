# Solidity API

## TransferReference

Reference implementation for the optimized Transfer target contract

### ERC20Transfer

```solidity
function ERC20Transfer(address _token, address _to, uint256 _value) external
```

Transfers an ERC-20 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of the token |
| _to | address | Target address |
| _value | uint256 | Transfer amount |

### ERC721TransferFrom

```solidity
function ERC721TransferFrom(address _token, address _from, address _to, uint256 _tokenId) external
```

Transfers an ERC-721 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of the token |
| _from | address | Source address |
| _to | address | Target address |
| _tokenId | uint256 | ID of the token |

### ERC1155TransferFrom

```solidity
function ERC1155TransferFrom(address _token, address _from, address _to, uint256 _id, uint256 _value) external
```

Transfers an ERC-1155 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of the token |
| _from | address | Source address |
| _to | address | Target address |
| _id | uint256 | ID of the token type |
| _value | uint256 | Transfer amount |

### ERC1155BatchTransferFrom

```solidity
function ERC1155BatchTransferFrom(address _token, address _from, address _to, uint256[] _ids, uint256[] _values) external
```

Batch transfers multiple ERC-1155 tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of the token |
| _from | address | Source address |
| _to | address | Target address |
| _ids | uint256[] | IDs of each token type |
| _values | uint256[] | Transfer amounts per token type |

