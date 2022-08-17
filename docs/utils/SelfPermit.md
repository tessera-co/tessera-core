# Solidity API

## SelfPermit

Utility contract for executing a permit signature to update the approval status in an FERC1155 contract

### selfPermit

```solidity
function selfPermit(address _token, uint256 _id, bool _approved, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public
```

Caller executes permit using their own signature for an ID type of an ERC1155 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of ERC1155 token contract |
| _id | uint256 | ID type being approved |
| _approved | bool | Approval status for the token |
| _deadline | uint256 | Deadline for when the signature expires |
| _v | uint8 | The recovery ID (129th byte and chain ID) of the signature used to recover the signer |
| _r | bytes32 | The first 64 bytes of the signature |
| _s | bytes32 | Bytes 64-128 of the signature |

### selfPermitAll

```solidity
function selfPermitAll(address _token, bool _approved, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public
```

Caller executes permit using their own signature for all ID types of an ERC1155 token

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | Address of ERC1155 token contract |
| _approved | bool | Approval status for the token |
| _deadline | uint256 | Deadline for when the signature expires |
| _v | uint8 | The recovery ID (129th byte and chain ID) of the signature used to recover the signer |
| _r | bytes32 | The first 64 bytes of the signature |
| _s | bytes32 | Bytes 64-128 of the signature |

