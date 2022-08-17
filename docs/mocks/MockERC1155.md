# Solidity API

## MockERC1155

### uri

```solidity
function uri(uint256) public pure virtual returns (string)
```

### mint

```solidity
function mint(address to, uint256 id, uint256 amount, bytes data) public virtual
```

### batchMint

```solidity
function batchMint(address to, uint256[] ids, uint256[] amounts, bytes data) public virtual
```

### burn

```solidity
function burn(address from, uint256 id, uint256 amount) public virtual
```

### batchBurn

```solidity
function batchBurn(address from, uint256[] ids, uint256[] amounts) public virtual
```

