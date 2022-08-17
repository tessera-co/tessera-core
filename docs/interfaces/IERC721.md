# Solidity API

## IERC721

_Interface for ERC-721 token contract_

### Approval

```solidity
event Approval(address _owner, address _spender, uint256 _id)
```

### ApprovalForAll

```solidity
event ApprovalForAll(address _owner, address _operator, bool _approved)
```

### Transfer

```solidity
event Transfer(address _from, address _to, uint256 _id)
```

### approve

```solidity
function approve(address _spender, uint256 _id) external
```

### balanceOf

```solidity
function balanceOf(address _owner) external view returns (uint256)
```

### getApproved

```solidity
function getApproved(uint256) external view returns (address)
```

### isApprovedForAll

```solidity
function isApprovedForAll(address, address) external view returns (bool)
```

### name

```solidity
function name() external view returns (string)
```

### ownerOf

```solidity
function ownerOf(uint256 _id) external view returns (address owner)
```

### safeTransferFrom

```solidity
function safeTransferFrom(address _from, address _to, uint256 _id) external
```

### safeTransferFrom

```solidity
function safeTransferFrom(address _from, address _to, uint256 _id, bytes _data) external
```

### setApprovalForAll

```solidity
function setApprovalForAll(address _operator, bool _approved) external
```

### supportsInterface

```solidity
function supportsInterface(bytes4 _interfaceId) external view returns (bool)
```

### symbol

```solidity
function symbol() external view returns (string)
```

### tokenURI

```solidity
function tokenURI(uint256 _id) external view returns (string)
```

### transferFrom

```solidity
function transferFrom(address _from, address _to, uint256 _id) external
```

