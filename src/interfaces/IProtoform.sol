// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IModule} from "./IModule.sol";

/// @dev Interface for generic Protoform contract
interface IProtoform {
    function deployVault(
        uint256 _fAmount,
        address[] calldata _modules,
        address[] calldata _plugins,
        bytes4[] calldata _selectors,
        bytes32[] calldata _proof
    ) external returns (address vault);

    function generateMerkleTree(address[] calldata _modules)
        external
        view
        returns (bytes32[] memory hashes);
}
