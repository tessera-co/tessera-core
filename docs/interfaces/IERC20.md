# Solidity API

## IERC20

_Interface for ERC-20 token contract_

### Approval

```solidity
event Approval(address _owner, address _spender, uint256 _amount)
```

### Transfer

```solidity
event Transfer(address _from, address _to, uint256 amount)
```

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32)
```

### allowance

```solidity
function allowance(address, address) external view returns (uint256)
```

### approve

```solidity
function approve(address _spender, uint256 _amount) external returns (bool)
```

### balanceOf

```solidity
function balanceOf(address) external view returns (uint256)
```

### decimals

```solidity
function decimals() external view returns (uint8)
```

### name

```solidity
function name() external view returns (string)
```

### nonces

```solidity
function nonces(address) external view returns (uint256)
```

### permit

```solidity
function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external
```

### symbol

```solidity
function symbol() external view returns (string)
```

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

### transfer

```solidity
function transfer(address _to, uint256 _amount) external returns (bool)
```

### transferFrom

```solidity
function transferFrom(address _from, address _to, uint256 _amount) external returns (bool)
```

