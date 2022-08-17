# Solidity API

## Buyout

Module contract for vaults to hold buyout pools
- A fractional owner starts an auction for a vault by depositing any amount of ether and fractional tokens into a pool.
- During the proposal period (2 days) users can sell their fractional tokens into the pool for ether.
- During the rejection period (4 days) users can buy fractional tokens from the pool with ether.
- If a pool has more than 50% of the total supply after 4 days, the buyout is successful and the proposer
  gains access to withdraw the underlying assets (ERC-20, ERC-721, and ERC-1155 tokens) from the vault.
  Otherwise the buyout is considered unsuccessful and a new one may then begin.
- NOTE: A vault may only have one active buyout at any given time.
- fractionPrice = ethAmount / (totalSupply - fractionAmount)
- buyoutPrice = fractionAmount * fractionPrice + ethAmount

### registry

```solidity
address registry
```

Address of VaultRegistry contract

### supply

```solidity
address supply
```

Address of Supply target contract

### transfer

```solidity
address transfer
```

Address of Transfer target contract

### PROPOSAL_PERIOD

```solidity
uint256 PROPOSAL_PERIOD
```

Time length of the proposal period

### REJECTION_PERIOD

```solidity
uint256 REJECTION_PERIOD
```

Time length of the rejection period

### buyoutInfo

```solidity
mapping(address => struct Auction) buyoutInfo
```

Mapping of vault address to auction struct

### constructor

```solidity
constructor(address _registry, address _supply, address _transfer) public
```

Initializes registry, supply, and transfer contracts

### receive

```solidity
receive() external payable
```

_Callback for receiving ether when the calldata is empty_

### start

```solidity
function start(address _vault, uint256 _amount) external payable
```

Starts the auction for a buyout pool

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _amount | uint256 | Number of fractional tokens deposited into pool |

### sellFractions

```solidity
function sellFractions(address _vault, uint256 _amount) external
```

Sells fractional tokens in exchange for ether from a pool

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _amount | uint256 | Transfer amount of fractions |

### buyFractions

```solidity
function buyFractions(address _vault, uint256 _amount) external payable
```

Buys fractional tokens in exchange for ether from a pool

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _amount | uint256 | Transfer amount of fractions |

### end

```solidity
function end(address _vault, bytes32[] _burnProof) external
```

Ends the auction for a live buyout pool

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _burnProof | bytes32[] | Merkle proof for burning fractional tokens |

### cash

```solidity
function cash(address _vault, bytes32[] _burnProof) external
```

Cashes out proceeds from a successful buyout

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _burnProof | bytes32[] | Merkle proof for burning fractional tokens |

### redeem

```solidity
function redeem(address _vault, bytes32[] _burnProof) external
```

Terminates a vault with an inactive buyout

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _burnProof | bytes32[] | Merkle proof for burning fractional tokens |

### withdrawERC20

```solidity
function withdrawERC20(address _vault, address _token, address _to, uint256 _value, bytes32[] _erc20TransferProof) external
```

Withdraws an ERC-20 token from a vault

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _token | address | Address of the token |
| _to | address | Address of the receiver |
| _value | uint256 | Transfer amount |
| _erc20TransferProof | bytes32[] | Merkle proof for transferring an ERC-20 token |

### withdrawERC721

```solidity
function withdrawERC721(address _vault, address _token, address _to, uint256 _tokenId, bytes32[] _erc721TransferProof) external
```

Withdraws an ERC-721 token from a vault

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _token | address | Address of the token |
| _to | address | Address of the receiver |
| _tokenId | uint256 | ID of the token |
| _erc721TransferProof | bytes32[] | Merkle proof for transferring an ERC-721 token |

### withdrawERC1155

```solidity
function withdrawERC1155(address _vault, address _token, address _to, uint256 _id, uint256 _value, bytes32[] _erc1155TransferProof) external
```

Withdraws an ERC-1155 token from a vault

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _token | address | Address of the token |
| _to | address | Address of the receiver |
| _id | uint256 | ID of the token type |
| _value | uint256 | Transfer amount |
| _erc1155TransferProof | bytes32[] | Merkle proof for transferring an ERC-1155 token |

### batchWithdrawERC1155

```solidity
function batchWithdrawERC1155(address _vault, address _token, address _to, uint256[] _ids, uint256[] _values, bytes32[] _erc1155BatchTransferProof) external
```

Batch withdraws ERC-1155 tokens from a vault

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _token | address | Address of the token |
| _to | address | Address of the receiver |
| _ids | uint256[] | IDs of each token type |
| _values | uint256[] | Transfer amounts per token type |
| _erc1155BatchTransferProof | bytes32[] | Merkle proof for transferring multiple ERC-1155 tokens |

### getLeafNodes

```solidity
function getLeafNodes() external view returns (bytes32[] nodes)
```

Gets the list of leaf nodes used to generate a merkle tree

_Leaf nodes are hashed permissions of the merkle tree_

| Name | Type | Description |
| ---- | ---- | ----------- |
| nodes | bytes32[] | Hashes of leaf nodes |

### getPermissions

```solidity
function getPermissions() public view returns (struct Permission[] permissions)
```

Gets the list of permissions installed on a vault

_Permissions consist of a module contract, target contract, and function selector_

| Name | Type | Description |
| ---- | ---- | ----------- |
| permissions | struct Permission[] | List of vault permissions |

### _terminateBuyout

```solidity
function _terminateBuyout(address _vault, address _to, uint256 _ethAmount) internal
```

_Terminates live pool and transfers remaining balance_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _to | address | Address of the proposer |
| _ethAmount | uint256 | Transfer amount |

