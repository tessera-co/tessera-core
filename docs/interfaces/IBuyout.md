# Solidity API

## State

```solidity
enum State {
  INACTIVE,
  LIVE,
  SUCCESS
}
```

## Auction

```solidity
struct Auction {
  uint256 startTime;
  address proposer;
  enum State state;
  uint256 fractionPrice;
  uint256 ethBalance;
  uint256 lastTotalSupply;
}
```

## IBuyout

_Interface for Buyout module contract_

### InvalidPayment

```solidity
error InvalidPayment()
```

_Emitted when the payment amount does not equal the fractional price_

### InvalidState

```solidity
error InvalidState(enum State _required, enum State _current)
```

_Emitted when the buyout state is invalid_

### NoFractions

```solidity
error NoFractions()
```

_Emitted when the caller has no balance of fractional tokens_

### NotWinner

```solidity
error NotWinner()
```

_Emitted when the caller is not the winner of an auction_

### NotVault

```solidity
error NotVault(address _vault)
```

_Emitted when the address is not a registered vault_

### TimeExpired

```solidity
error TimeExpired(uint256 _current, uint256 _deadline)
```

_Emitted when the time has expired for selling and buying fractions_

### TimeNotElapsed

```solidity
error TimeNotElapsed(uint256 _current, uint256 _deadline)
```

_Emitted when the buyout auction is still active_

### ZeroDeposit

```solidity
error ZeroDeposit()
```

_Emitted when ether deposit amount for starting a buyout is zero_

### Start

```solidity
event Start(address _vault, address _proposer, uint256 _startTime, uint256 _buyoutPrice, uint256 _fractionPrice)
```

_Event log for starting a buyout_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _proposer | address | Address that created the buyout |
| _startTime | uint256 | Timestamp of when buyout was created |
| _buyoutPrice | uint256 | Price of buyout pool in ether |
| _fractionPrice | uint256 | Price of fractional tokens |

### SellFractions

```solidity
event SellFractions(address _seller, uint256 _amount)
```

_Event log for selling fractional tokens into the buyout pool_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _seller | address | Address selling fractions |
| _amount | uint256 | Transfer amount being sold |

### BuyFractions

```solidity
event BuyFractions(address _buyer, uint256 _amount)
```

_Event log for buying fractional tokens from the buyout pool_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _buyer | address | Address buying fractions |
| _amount | uint256 | Transfer amount being bought |

### End

```solidity
event End(address _vault, enum State _state, address _proposer)
```

_Event log for ending an active buyout_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _state | enum State | Enum state of auction |
| _proposer | address | Address that created the buyout |

### Cash

```solidity
event Cash(address _vault, address _casher, uint256 _amount)
```

_Event log for cashing out ether for fractions from a successful buyout_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _casher | address | Address cashing out of buyout |
| _amount | uint256 | Transfer amount of ether |

### Redeem

```solidity
event Redeem(address _vault, address _redeemer)
```

_Event log for redeeming the underlying vault assets from an inactive buyout_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vault | address | Address of the vault |
| _redeemer | address | Address redeeming underlying assets |

### PROPOSAL_PERIOD

```solidity
function PROPOSAL_PERIOD() external view returns (uint256)
```

### REJECTION_PERIOD

```solidity
function REJECTION_PERIOD() external view returns (uint256)
```

### batchWithdrawERC1155

```solidity
function batchWithdrawERC1155(address _vault, address _token, address _to, uint256[] _ids, uint256[] _values, bytes32[] _erc1155BatchTransferProof) external
```

### buyFractions

```solidity
function buyFractions(address _vault, uint256 _amount) external payable
```

### buyoutInfo

```solidity
function buyoutInfo(address) external view returns (uint256 startTime, address proposer, enum State state, uint256 fractionPrice, uint256 ethBalance, uint256 lastTotalSupply)
```

### cash

```solidity
function cash(address _vault, bytes32[] _burnProof) external
```

### end

```solidity
function end(address _vault, bytes32[] _burnProof) external
```

### getLeafNodes

```solidity
function getLeafNodes() external view returns (bytes32[] nodes)
```

### getPermissions

```solidity
function getPermissions() external view returns (struct Permission[] permissions)
```

### redeem

```solidity
function redeem(address _vault, bytes32[] _burnProof) external
```

### registry

```solidity
function registry() external view returns (address)
```

### sellFractions

```solidity
function sellFractions(address _vault, uint256 _amount) external
```

### start

```solidity
function start(address _vault, uint256 _amount) external payable
```

### supply

```solidity
function supply() external view returns (address)
```

### transfer

```solidity
function transfer() external view returns (address)
```

### withdrawERC20

```solidity
function withdrawERC20(address _vault, address _token, address _to, uint256 _value, bytes32[] _erc20TransferProof) external
```

### withdrawERC721

```solidity
function withdrawERC721(address _vault, address _token, address _to, uint256 _tokenId, bytes32[] _erc721TransferProof) external
```

### withdrawERC1155

```solidity
function withdrawERC1155(address _vault, address _token, address _to, uint256 _id, uint256 _value, bytes32[] _erc1155TransferProof) external
```

