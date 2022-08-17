# Solidity API

## ISupply

_Interface for Supply target contract_

### MintError

```solidity
error MintError(address _account)
```

_Emitted when an account being called as an assumed contract does not have code and returns no data_

### BurnError

```solidity
error BurnError(address _account)
```

_Emitted when an account being called as an assumed contract does not have code and returns no data_

### mint

```solidity
function mint(address _to, uint256 _value) external
```

### burn

```solidity
function burn(address _from, uint256 _value) external
```

