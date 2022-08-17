# Solidity API

## MerkleBase

Utility contract for generating merkle roots and verifying proofs

### constructor

```solidity
constructor() internal
```

### hashLeafPairs

```solidity
function hashLeafPairs(bytes32 _left, bytes32 _right) public pure returns (bytes32 data)
```

Hashes two leaf pairs

| Name | Type | Description |
| ---- | ---- | ----------- |
| _left | bytes32 | Node on left side of tree level |
| _right | bytes32 | Node on right side of tree level |

| Name | Type | Description |
| ---- | ---- | ----------- |
| data | bytes32 | Result hash of node params |

### verifyProof

```solidity
function verifyProof(bytes32 _root, bytes32[] _proof, bytes32 _valueToProve) public pure returns (bool)
```

Verifies the merkle proof of a given value

| Name | Type | Description |
| ---- | ---- | ----------- |
| _root | bytes32 | Hash of merkle root |
| _proof | bytes32[] | Merkle proof |
| _valueToProve | bytes32 | Leaf node being proven |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | Status of proof verification |

### getRoot

```solidity
function getRoot(bytes32[] _data) public pure returns (bytes32)
```

Generates the merkle root of a tree

| Name | Type | Description |
| ---- | ---- | ----------- |
| _data | bytes32[] | Leaf nodes of the merkle tree |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | Hash of merkle root |

### getProof

```solidity
function getProof(bytes32[] _data, uint256 _node) public pure returns (bytes32[])
```

Generates the merkle proof for a leaf node in a given tree

| Name | Type | Description |
| ---- | ---- | ----------- |
| _data | bytes32[] | Leaf nodes of the merkle tree |
| _node | uint256 | Index of the node in the tree |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32[] | Merkle proof |

### hashLevel

```solidity
function hashLevel(bytes32[] _data) private pure returns (bytes32[] result)
```

_Hashes nodes at the given tree level_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _data | bytes32[] | Nodes at the current level |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | bytes32[] | Hashes of nodes at the next level |

### log2ceil_naive

```solidity
function log2ceil_naive(uint256 x) public pure returns (uint256 ceil)
```

Calculates proof size based on size of tree

_Note that x is assumed > 0 and proof size is not precise_

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | uint256 | Size of the merkle tree |

| Name | Type | Description |
| ---- | ---- | ----------- |
| ceil | uint256 | Rounded value of proof size |

