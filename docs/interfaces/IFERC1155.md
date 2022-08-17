# Solidity API

## IFERC1155

_Interface of ERC-1155 token contract for fractions_

### InvalidSender

```solidity
error InvalidSender(address _required, address _provided)
```

_Emitted when caller is not required address_

### InvalidSignature

```solidity
error InvalidSignature(address _signer, address _owner)
```

_Emitted when owner signature is invalid_

### SignatureExpired

```solidity
error SignatureExpired(uint256 _timestamp, uint256 _deadline)
```

_Emitted when deadline for signature has passed_

### InvalidRoyalty

```solidity
error InvalidRoyalty(uint256 _percentage)
```

_Emitted when royalty is set to value greater than 100%_

### ZeroAddress

```solidity
error ZeroAddress()
```

_Emitted when new controller is zero address_

### ControllerTransferred

```solidity
event ControllerTransferred(address _newController)
```

_Event log for updating the Controller of the token contract_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newController | address | Address of the controller |

### SetMetadata

```solidity
event SetMetadata(address _metadata, uint256 _id)
```

_Event log for updating the metadata contract for a token type_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _metadata | address | Address of the metadata contract that URI data is stored on |
| _id | uint256 | ID of the token type |

### SetRoyalty

```solidity
event SetRoyalty(address _receiver, uint256 _id, uint256 _percentage)
```

_Event log for updating the royalty of a token type_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _receiver | address | Address of the receiver of secondary sale royalties |
| _id | uint256 | ID of the token type |
| _percentage | uint256 | Royalty percent on secondary sales |

### SingleApproval

```solidity
event SingleApproval(address _owner, address _operator, uint256 _id, bool _approved)
```

_Event log for approving a spender of a token type_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | Address of the owner of the token type |
| _operator | address | Address of the spender of the token type |
| _id | uint256 | ID of the token type |
| _approved | bool | Approval status for the token type |

### INITIAL_CONTROLLER

```solidity
function INITIAL_CONTROLLER() external pure returns (address)
```

### VAULT_REGISTRY

```solidity
function VAULT_REGISTRY() external pure returns (address)
```

### burn

```solidity
function burn(address _from, uint256 _id, uint256 _amount) external
```

### contractURI

```solidity
function contractURI() external view returns (string)
```

### controller

```solidity
function controller() external view returns (address controllerAddress)
```

### emitSetURI

```solidity
function emitSetURI(uint256 _id, string _uri) external
```

### isApproved

```solidity
function isApproved(address, address, uint256) external view returns (bool)
```

### metadata

```solidity
function metadata(uint256) external view returns (address)
```

### mint

```solidity
function mint(address _to, uint256 _id, uint256 _amount, bytes _data) external
```

### permit

```solidity
function permit(address _owner, address _operator, uint256 _id, bool _approved, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external
```

### permitAll

```solidity
function permitAll(address _owner, address _operator, bool _approved, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external
```

### royaltyInfo

```solidity
function royaltyInfo(uint256 _id, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount)
```

### safeTransferFrom

```solidity
function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes _data) external
```

### setApprovalFor

```solidity
function setApprovalFor(address _operator, uint256 _id, bool _approved) external
```

### setContractURI

```solidity
function setContractURI(string _uri) external
```

### setMetadata

```solidity
function setMetadata(address _metadata, uint256 _id) external
```

### setRoyalties

```solidity
function setRoyalties(uint256 _id, address _receiver, uint256 _percentage) external
```

### totalSupply

```solidity
function totalSupply(uint256) external view returns (uint256)
```

### transferController

```solidity
function transferController(address _newController) external
```

### uri

```solidity
function uri(uint256 _id) external view returns (string)
```

