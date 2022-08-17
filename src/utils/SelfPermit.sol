// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IFERC1155} from "../interfaces/IFERC1155.sol";

/// @title SelfPermit
/// @author Modified from Uniswap (https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/SelfPermit.sol)
/// @notice Utility contract for executing a permit signature to update the approval status in an FERC1155 contract
abstract contract SelfPermit {
    /// @notice Caller executes permit using their own signature for an ID type of an ERC1155 token
    /// @param _token Address of ERC1155 token contract
    /// @param _id ID type being approved
    /// @param _approved Approval status for the token
    /// @param _deadline Deadline for when the signature expires
    /// @param _v The recovery ID (129th byte and chain ID) of the signature used to recover the signer
    /// @param _r The first 64 bytes of the signature
    /// @param _s Bytes 64-128 of the signature
    function selfPermit(
        address _token,
        uint256 _id,
        bool _approved,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        IFERC1155(_token).permit(
            msg.sender,
            address(this),
            _id,
            _approved,
            _deadline,
            _v,
            _r,
            _s
        );
    }

    /// @notice Caller executes permit using their own signature for all ID types of an ERC1155 token
    /// @param _token Address of ERC1155 token contract
    /// @param _approved Approval status for the token
    /// @param _deadline Deadline for when the signature expires
    /// @param _v The recovery ID (129th byte and chain ID) of the signature used to recover the signer
    /// @param _r The first 64 bytes of the signature
    /// @param _s Bytes 64-128 of the signature
    function selfPermitAll(
        address _token,
        bool _approved,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        IFERC1155(_token).permitAll(
            msg.sender,
            address(this),
            _approved,
            _deadline,
            _v,
            _r,
            _s
        );
    }
}
