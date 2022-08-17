# Solidity API

## Metadata

Utility contract for storing metadata of an FERC1155 token

### token

```solidity
address token
```

Address of FERC1155 token contract

### tokenMetadata

```solidity
mapping(uint256 => string) tokenMetadata
```

_Mapping of ID type to URI of metadata_

### constructor

```solidity
constructor(address _token) public
```

Initializes token contract

### setURI

```solidity
function setURI(uint256 _id, string _uri) external
```

Sets the metadata of a given token ID type

_Can only be set by the token controller_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint256 | ID of the token type |
| _uri | string | URI of the token metadata |

### uri

```solidity
function uri(uint256 _id) public view returns (string)
```

Gets the metadata of a token ID type

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint256 | ID of the token type |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | URI of the token metadata |

