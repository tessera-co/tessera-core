# Solidity API

## PermitBase

Utility contract for computing permit signature approvals for FERC1155 tokens

### nonces

```solidity
mapping(address => uint256) nonces
```

Mapping of token owner to nonce value

### _computePermitStructHash

```solidity
function _computePermitStructHash(address _owner, address _operator, uint256 _id, bool _approved, uint256 _deadline) internal returns (bytes32)
```

_Computes hash of permit struct_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | Address of the owner of the token type |
| _operator | address | Address of the spender of the token type |
| _id | uint256 | ID of the token type |
| _approved | bool | Approval status for the token type |
| _deadline | uint256 | Expiration of the signature |

### _computePermitAllStructHash

```solidity
function _computePermitAllStructHash(address _owner, address _operator, bool _approved, uint256 _deadline) internal returns (bytes32)
```

_Computes hash of permit all struct_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | Address of the owner of the token type |
| _operator | address | Address of the spender of the token type |
| _approved | bool | Approval status for the token type |
| _deadline | uint256 | Expiration of the signature |

### _computeDomainSeparator

```solidity
function _computeDomainSeparator() internal view returns (bytes32)
```

_Computes domain separator to prevent signature collisions_

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | Hash of the contract-specific fields |

### _computeDigest

```solidity
function _computeDigest(bytes32 _domainSeparator, bytes32 _structHash) internal pure returns (bytes32)
```

_Computes digest of domain separator and struct hash_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _domainSeparator | bytes32 | Hash of contract-specific fields |
| _structHash | bytes32 | Hash of signature fields struct |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | Hash of the signature digest |

