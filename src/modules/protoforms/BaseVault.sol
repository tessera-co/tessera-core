// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IBaseVault} from "../../interfaces/IBaseVault.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {IERC721} from "../../interfaces/IERC721.sol";
import {IERC1155} from "../../interfaces/IERC1155.sol";
import {IModule} from "../../interfaces/IProtoform.sol";
import {IVaultRegistry, Permission} from "../../interfaces/IVaultRegistry.sol";
import {MerkleBase} from "../../utils/MerkleBase.sol";
import {Minter} from "../Minter.sol";
import {Multicall} from "../../utils/Multicall.sol";

/// @title BaseVault
/// @author Fractional Art
/// @notice Protoform contract for vault deployments with a fixed supply and buyout mechanism
contract BaseVault is IBaseVault, MerkleBase, Minter, Multicall {
    /// @notice Address of VaultRegistry contract
    address public registry;

    /// @notice Initializes registry and supply contracts
    /// @param _registry Address of the VaultRegistry contract
    /// @param _supply Address of the Supply target contract
    constructor(address _registry, address _supply) Minter(_supply) {
        registry = _registry;
    }

    /// @notice Deploys a new Vault and mints initial supply of fractions
    /// @param _fractionSupply Number of NFT Fractions minted to control the vault
    /// @param _modules The list of modules to be installed on the vault
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @param _mintProof List of proofs to execute a mint function
    function deployVault(
        uint256 _fractionSupply,
        address[] calldata _modules,
        address[] calldata _plugins,
        bytes4[] calldata _selectors,
        bytes32[] calldata _mintProof
    ) external returns (address vault) {
        bytes32[] memory leafNodes = generateMerkleTree(_modules);
        bytes32 merkleRoot = getRoot(leafNodes);
        vault = IVaultRegistry(registry).create(
            merkleRoot,
            _plugins,
            _selectors
        );
        emit ActiveModules(vault, _modules);

        _mintFractions(vault, msg.sender, _fractionSupply, _mintProof);
    }

    /// @notice Transfers ERC-20 tokens
    /// @param _to Target address
    /// @param _tokens[] Addresses of token contracts
    /// @param _amounts[] Transfer amounts
    function batchDepositERC20(
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _amounts
    ) external {
        for (uint256 i = 0; i < _tokens.length; ) {
            require(IERC20(_tokens[i]).transferFrom(msg.sender, _to, _amounts[i]), "ERC20: transferFrom is fall");
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Transfers ERC-721 tokens
    /// @param _to Target address
    /// @param _tokens[] Addresses of token contracts
    /// @param _ids[] IDs of the tokens
    function batchDepositERC721(
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _ids
    ) external {
        for (uint256 i = 0; i < _tokens.length; ) {
            IERC721(_tokens[i]).safeTransferFrom(msg.sender, _to, _ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Transfers ERC-1155 tokens
    /// @param _to Target address
    /// @param _tokens[] Addresses of token contracts
    /// @param _ids[] Ids of the token types
    /// @param _amounts[] Transfer amounts
    /// @param _datas[] Additional transaction data
    function batchDepositERC1155(
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes[] calldata _datas
    ) external {
        unchecked {
            for (uint256 i = 0; i < _tokens.length; ++i) {
                IERC1155(_tokens[i]).safeTransferFrom(
                    msg.sender,
                    _to,
                    _ids[i],
                    _amounts[i],
                    _datas[i]
                );
            }
        }
    }

    /// @notice Generates a merkle tree from the hashed permission lists of the given modules
    /// @param _modules List of module contracts
    /// @return hashes A combined list of leaf nodes
    function generateMerkleTree(address[] calldata _modules)
        public
        view
        returns (bytes32[] memory hashes)
    {
        uint256 counter;
        hashes = new bytes32[](6);
        unchecked {
            for (uint256 i; i < _modules.length; ++i) {
                bytes32[] memory leaves = IModule(_modules[i]).getLeafNodes();
                for (uint256 j; j < leaves.length; ++j) {
                    hashes[counter++] = leaves[j];
                }
            }
        }
    }
}
