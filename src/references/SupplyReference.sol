// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ISupply} from "../interfaces/ISupply.sol";
import {IVaultRegistry} from "../interfaces/IVaultRegistry.sol";

/// @title Supply
/// @author Fractional Art
/// @notice Reference implementation for the optimized Supply target contract
contract SupplyReference is ISupply {
    /// @notice Address of VaultRegistry contract
    address immutable registry;

    /// @notice Initializes address of registry contract
    constructor(address _registry) {
        registry = _registry;
    }

    /// @notice Mints fractional tokens
    /// @param _to Target address
    /// @param _value Transfer amount
    function mint(address _to, uint256 _value) external {
        IVaultRegistry(registry).mint(_to, _value);
    }

    /// @notice Burns fractional tokens
    /// @param _from Source address
    /// @param _value Burn amount
    function burn(address _from, uint256 _value) external {
        IVaultRegistry(registry).burn(_from, _value);
    }
}
