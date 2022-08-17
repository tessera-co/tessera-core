# Solidity API

## Transfer

Target contract for transferring fungible and non-fungible tokens

### ERC20Transfer

```solidity
function ERC20Transfer(address _token, address _to, uint256 _amount) external
```

Transfers an ERC-20 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of the token |
| _to | address | Target address |
| _amount | uint256 | Transfer amount |

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
function ERC1155TransferFrom(address _token, address _from, address _to, uint256 _tokenId, uint256 _amount) external
```

Transfers an ERC-1155 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | token to transfer |
| _from | address | Source address |
| _to | address | Target address |
| _tokenId | uint256 | ID of the token type |
| _amount | uint256 | Transfer amount |

### ERC1155BatchTransferFrom

```solidity
function ERC1155BatchTransferFrom(address, address, address, uint256[], uint256[]) external
```

Batch transfers multiple ERC-1155 tokens

