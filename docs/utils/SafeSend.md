# Solidity API

## SafeSend

Utility contract for sending Ether or WETH value to an address

### WETH_ADDRESS

```solidity
address payable WETH_ADDRESS
```

Address for WETH contract on mainnet

### _attemptETHTransfer

```solidity
function _attemptETHTransfer(address _to, uint256 _value) internal returns (bool success)
```

Attempts to send ether to an address

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Address attemping to send to |
| _value | uint256 | Amount to send |

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | Status of transfer |

### _sendEthOrWeth

```solidity
function _sendEthOrWeth(address _to, uint256 _value) internal
```

Sends eth or weth to an address

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | Address to send to |
| _value | uint256 | Amount to send |

