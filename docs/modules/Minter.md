# Solidity API

## Minter

Module contract for minting a fixed supply of fractions

### supply

```solidity
address supply
```

Address of Supply target contract

### constructor

```solidity
constructor(address _supply) public
```

Initializes supply target contract

### getLeafNodes

```solidity
function getLeafNodes() external view returns (bytes32[] nodes)
```

Gets the list of leaf nodes used to generate a merkle tree

_Leaf nodes are hashed permissions of the merkle tree_

| Name | Type | Description |
| ---- | ---- | ----------- |
| nodes | bytes32[] | A list of leaf nodes |

### getPermissions

```solidity
function getPermissions() public view returns (struct Permission[] permissions)
```

Gets the list of permissions installed on a vault

_Permissions consist of a module contract, target contract, and function selector_

| Name | Type | Description |
| ---- | ---- | ----------- |
| permissions | struct Permission[] | A list of Permission Structs |

### _mintFractions

```solidity
function _mintFractions(address _vault, address _to, uint256 _fractionSupply, bytes32[] _mintProof) internal
```

Mints a fraction supply

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the Vault |
| _to | address | Address of the receiver of fractions |
| _fractionSupply | uint256 | Number of NFT Fractions minted to control the vault |
| _mintProof | bytes32[] | List of proofs to execute a mint function |

