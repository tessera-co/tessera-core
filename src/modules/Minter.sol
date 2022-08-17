// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IMinter} from "../interfaces/IMinter.sol";
import {ISupply} from "../interfaces/ISupply.sol";
import {IVault} from "../interfaces/IVault.sol";
import {Permission} from "../interfaces/IVaultRegistry.sol";

/// @title Minter
/// @author Fractional Art
/// @notice Module contract for minting a fixed supply of fractions
contract Minter is IMinter {
    /// @notice Address of Supply target contract
    address public supply;

    /// @notice Initializes supply target contract
    constructor(address _supply) {
        supply = _supply;
    }

    /// @notice Gets the list of leaf nodes used to generate a merkle tree
    /// @dev Leaf nodes are hashed permissions of the merkle tree
    /// @return nodes A list of leaf nodes
    function getLeafNodes() external view returns (bytes32[] memory nodes) {
        nodes = new bytes32[](1);
        nodes[0] = keccak256(abi.encode(getPermissions()[0]));
    }

    /// @notice Gets the list of permissions installed on a vault
    /// @dev Permissions consist of a module contract, target contract, and function selector
    /// @return permissions A list of Permission Structs
    function getPermissions()
        public
        view
        returns (Permission[] memory permissions)
    {
        permissions = new Permission[](1);
        permissions[0] = Permission(
            address(this),
            supply,
            ISupply.mint.selector
        );
    }

    /// @notice Mints a fraction supply
    /// @param _vault Address of the Vault
    /// @param _to Address of the receiver of fractions
    /// @param _fractionSupply Number of NFT Fractions minted to control the vault
    /// @param _mintProof List of proofs to execute a mint function
    function _mintFractions(
        address _vault,
        address _to,
        uint256 _fractionSupply,
        bytes32[] calldata _mintProof
    ) internal {
        bytes memory data = abi.encodeCall(
            ISupply.mint,
            (_to, _fractionSupply)
        );
        IVault(payable(_vault)).execute(supply, data, _mintProof);
    }
}
