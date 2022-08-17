// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IFERC1155} from "../interfaces/IFERC1155.sol";

/// @title Metadata
/// @author Fractional Art
/// @notice Utility contract for storing metadata of an FERC1155 token
contract Metadata {
    /// @notice Address of FERC1155 token contract
    address immutable token;
    /// @dev Mapping of ID type to URI of metadata
    mapping(uint256 => string) private tokenMetadata;

    /// @notice Initializes token contract
    constructor(address _token) {
        token = _token;
    }

    /// @notice Sets the metadata of a given token ID type
    /// @dev Can only be set by the token controller
    /// @param _uri URI of the token metadata
    /// @param _id ID of the token type
    function setURI(uint256 _id, string memory _uri) external {
        address controller = IFERC1155(token).controller();
        if (msg.sender != controller)
            revert IFERC1155.InvalidSender(controller, msg.sender);

        tokenMetadata[_id] = _uri;
        IFERC1155(token).emitSetURI(_id, _uri);
    }

    /// @notice Gets the metadata of a token ID type
    /// @param _id ID of the token type
    /// @return URI of the token metadata
    function uri(uint256 _id) public view returns (string memory) {
        return tokenMetadata[_id];
    }
}
