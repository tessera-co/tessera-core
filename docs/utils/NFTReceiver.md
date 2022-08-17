# Solidity API

## NFTReceiver

Plugin contract for handling receipts of non-fungible tokens

### onERC721Received

```solidity
function onERC721Received(address, address, uint256, bytes) external virtual returns (bytes4)
```

Handles the receipt of a single ERC721 token

### onERC1155Received

```solidity
function onERC1155Received(address, address, uint256, uint256, bytes) external virtual returns (bytes4)
```

Handles the receipt of a single ERC1155 token type

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) external virtual returns (bytes4)
```

Handles the receipt of multiple ERC1155 token types

