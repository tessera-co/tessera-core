// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import { ExampleClone } from "./ExampleClone.sol";
import { ClonesWithImmutableArgs } from "./ClonesWithImmutableArgs.sol";

contract ExampleCloneFactory {
    using ClonesWithImmutableArgs for address;

    ExampleClone public implementation;

    constructor(ExampleClone implementation_) {
        implementation = implementation_;
    }

    function createClone(
        address param1,
        uint256 param2,
        uint64 param3,
        bytes32 param4,
        uint8 param5
    ) external returns (ExampleClone clone) {
        bytes memory data = abi.encodePacked(
            param1,
            param2,
            param3,
            param4,
            param5
        );
        clone = ExampleClone(address(implementation).clone(data));
    }
}
