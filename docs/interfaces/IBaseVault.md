# Solidity API

## IBaseVault

_Interface for BaseVault protoform contract_

### ActiveModules

```solidity
event ActiveModules(address _vault, address[] _modules)
```

_Event log for modules that are enabled on a vault_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | The vault deployed |
| _modules | address[] | The modules being activated on deployed vault |

### batchDepositERC20

```solidity
function batchDepositERC20(address _to, address[] _tokens, uint256[] _amounts) external
```

### batchDepositERC721

```solidity
function batchDepositERC721(address _to, address[] _tokens, uint256[] _ids) external
```

### batchDepositERC1155

```solidity
function batchDepositERC1155(address _to, address[] _tokens, uint256[] _ids, uint256[] _amounts, bytes[] _datas) external
```

### deployVault

```solidity
function deployVault(uint256 _fractionSupply, address[] _modules, address[] _plugins, bytes4[] _selectors, bytes32[] _mintProof) external returns (address vault)
```

### registry

```solidity
function registry() external view returns (address)
```

