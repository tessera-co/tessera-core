// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IModule} from "./IModule.sol";
import {Permission} from "./IVaultRegistry.sol";

/// @dev Interface for Minter module contract
interface IMinter is IModule {
    function supply() external view returns (address);
}
