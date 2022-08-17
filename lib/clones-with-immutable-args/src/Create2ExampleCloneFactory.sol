// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import { ExampleClone } from "./ExampleClone.sol";
import { Create2ClonesWithImmutableArgs } from "./Create2ClonesWithImmutableArgs.sol";

contract Create2ExampleCloneFactory {
    using Create2ClonesWithImmutableArgs for address;

    /// @dev Internal mapping to track the next seed to be used by an EOA.
    mapping(address => uint256) internal nextSeeds;
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
        uint256 seed = nextSeeds[tx.origin]++;
        bytes32 salt = keccak256(abi.encode(tx.origin, seed));
        bytes memory data = abi.encodePacked(
            param1,
            param2,
            param3,
            param4,
            param5
        );
        clone = ExampleClone(address(implementation).clone(salt, data));
    }

    /// @dev Returns the address where a clone of implementation will be deployed by this factory.
    /// @param implementation - is the address of the clone you want to Clone
    /// @param data - abi.encodePacked param list
    function computeCloneAddress(address implementation, bytes memory data)
        external
        view
        returns (address predicted)
    {
        uint256 seed = nextSeeds[tx.origin];
        bytes32 salt = keccak256(abi.encode(tx.origin, seed));
        (uint256 creationPtr, uint256 creationSize) = implementation
            .cloneCreationCode(data);

        bytes32 creationHash;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            creationHash := keccak256(creationPtr, creationSize)
        }
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, creationHash)
        );
        return address(uint160(uint256(_data)));
    }
}
