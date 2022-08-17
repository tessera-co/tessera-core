// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IProtoform} from "./IProtoform.sol";

/// @dev Interface for BaseVault protoform contract
interface IBaseVault is IProtoform {
    /// @dev Event log for modules that are enabled on a vault
    /// @param _vault The vault deployed
    /// @param _modules The modules being activated on deployed vault
    event ActiveModules(address indexed _vault, address[] _modules);

    function batchDepositERC20(
        address _to,
        address[] memory _tokens,
        uint256[] memory _amounts
    ) external;

    function batchDepositERC721(
        address _to,
        address[] memory _tokens,
        uint256[] memory _ids
    ) external;

    function batchDepositERC1155(
        address _to,
        address[] memory _tokens,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes[] memory _datas
    ) external;

    function deployVault(
        uint256 _fractionSupply,
        address[] memory _modules,
        address[] calldata _plugins,
        bytes4[] calldata _selectors,
        bytes32[] memory _mintProof
    ) external returns (address vault);

    function registry() external view returns (address);
}
