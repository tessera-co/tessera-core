# Solidity API

## INFTReceiver

_Interface for NFT Receiver contract_

### onERC721Received

```solidity
function onERC721Received(address, address, uint256, bytes) external returns (bytes4)
```

### onERC1155Received

```solidity
function onERC1155Received(address, address, uint256, uint256, bytes) external returns (bytes4)
```

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) external returns (bytes4)
```

