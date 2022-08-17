# Solidity API

## IProtoform

_Interface for generic Protoform contract_

### deployVault

```solidity
function deployVault(uint256 _fAmount, address[] _modules, address[] _plugins, bytes4[] _selectors, bytes32[] _proof) external returns (address vault)
```

### generateMerkleTree

```solidity
function generateMerkleTree(address[] _modules) external view returns (bytes32[] hashes)
```

