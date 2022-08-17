# Solidity API

## SupplyReference

Reference implementation for the optimized Supply target contract

### registry

```solidity
address registry
```

Address of VaultRegistry contract

### constructor

```solidity
constructor(address _registry) public
```

Initializes address of registry contract

### mint

```solidity
function mint(address _to, uint256 _value) external
```

Mints fractional tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Target address |
| _value | uint256 | Transfer amount |

### burn

```solidity
function burn(address _from, uint256 _value) external
```

Burns fractional tokens

| Name | Type | Description |
| ---- | ---- | ----------- |
| _from | address | Source address |
| _value | uint256 | Burn amount |

