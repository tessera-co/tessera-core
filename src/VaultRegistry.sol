// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ClonesWithImmutableArgs} from "clones-with-immutable-args/src/ClonesWithImmutableArgs.sol";
import {FERC1155} from "./FERC1155.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IVaultRegistry, VaultInfo} from "./interfaces/IVaultRegistry.sol";
import {VaultFactory} from "./VaultFactory.sol";

/// @title Vault Registry
/// @author Fractional Art
/// @notice Registry contract for tracking all fractional vaults
contract VaultRegistry is IVaultRegistry {
    /// @dev Use clones library with address types
    using ClonesWithImmutableArgs for address;
    /// @notice Address of VaultFactory contract
    address public immutable factory;
    /// @notice Address of FERC1155 token contract
    address public immutable fNFT;
    /// @notice Address of Implementation for FERC1155 token contract
    address public immutable fNFTImplementation;
    /// @notice Mapping of collection address to next token ID type
    mapping(address => uint256) public nextId;
    /// @notice Mapping of vault address to vault information
    mapping(address => VaultInfo) public vaultToToken;

    /// @notice Initializes factory, implementation, and token contracts
    constructor() {
        factory = address(new VaultFactory());
        fNFTImplementation = address(new FERC1155());
        fNFT = fNFTImplementation.clone(
            abi.encodePacked(msg.sender, address(this))
        );
    }

    /// @notice Burns vault tokens
    /// @param _from Source address
    /// @param _value Amount of tokens
    function burn(address _from, uint256 _value) external {
        VaultInfo memory info = vaultToToken[msg.sender];
        uint256 id = info.id;
        if (id == 0) revert UnregisteredVault(msg.sender);
        FERC1155(info.token).burn(_from, id, _value);
    }

    /// @notice Creates a new vault with permissions and plugins
    /// @param _merkleRoot Hash of merkle root for vault permissions
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @return vault Address of Proxy contract
    function create(
        bytes32 _merkleRoot,
        address[] calldata _plugins,
        bytes4[] calldata _selectors
    ) external returns (address vault) {
        vault = _deployVault(
            _merkleRoot,
            address(this),
            fNFT,
            _plugins,
            _selectors
        );
    }

    /// @notice Creates a new vault with permissions and plugins, and transfers ownership to a given owner
    /// @dev This should only be done in limited cases i.e. if you're okay with a trusted individual(s)
    /// having control over the vault. Ideally, execution would be locked behind a Multisig wallet.
    /// @param _merkleRoot Hash of merkle root for vault permissions
    /// @param _owner Address of the vault owner
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @return vault Address of Proxy contract
    function createFor(
        bytes32 _merkleRoot,
        address _owner,
        address[] calldata _plugins,
        bytes4[] calldata _selectors
    ) external returns (address vault) {
        vault = _deployVault(_merkleRoot, _owner, fNFT, _plugins, _selectors);
    }

    /// @notice Creates a new vault with permissions and plugins for the message sender
    /// @param _merkleRoot Hash of merkle root for vault permissions
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @return vault Address of Proxy contract
    /// @return token Address of FERC1155 contract
    function createCollection(
        bytes32 _merkleRoot,
        address[] calldata _plugins,
        bytes4[] calldata _selectors
    ) external returns (address vault, address token) {
        (vault, token) = createCollectionFor(
            _merkleRoot,
            msg.sender,
            _plugins,
            _selectors
        );
    }

    /// @notice Creates a new vault with permissions and plugins for an existing collection
    /// @param _merkleRoot Hash of merkle root for vault permissions
    /// @param _token Address of FERC1155 contract
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @return vault Address of Proxy contract
    function createInCollection(
        bytes32 _merkleRoot,
        address _token,
        address[] calldata _plugins,
        bytes4[] calldata _selectors
    ) external returns (address vault) {
        address controller = FERC1155(_token).controller();
        if (controller != msg.sender)
            revert InvalidController(controller, msg.sender);
        vault = _deployVault(
            _merkleRoot,
            address(this),
            _token,
            _plugins,
            _selectors
        );
    }

    /// @notice Mints vault tokens
    /// @param _to Target address
    /// @param _value Amount of tokens
    function mint(address _to, uint256 _value) external {
        VaultInfo memory info = vaultToToken[msg.sender];
        uint256 id = info.id;
        if (id == 0) revert UnregisteredVault(msg.sender);
        FERC1155(info.token).mint(_to, id, _value, "");
    }

    /// @notice Gets the total supply for a token and ID associated with a vault
    /// @param _vault Address of the vault
    /// @return Total supply
    function totalSupply(address _vault) external view returns (uint256) {
        VaultInfo memory info = vaultToToken[_vault];
        return FERC1155(info.token).totalSupply(info.id);
    }

    /// @notice Gets the uri for a given token and ID associated with a vault
    /// @param _vault Address of the vault
    /// @return URI of token
    function uri(address _vault) external view returns (string memory) {
        VaultInfo memory info = vaultToToken[_vault];
        return FERC1155(info.token).uri(info.id);
    }

    /// @notice Creates a new vault with permissions and plugins for a given controller
    /// @param _merkleRoot Hash of merkle root for vault permissions
    /// @param _controller Address of token controller
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @return vault Address of Proxy contract
    /// @return token Address of FERC1155 contract
    function createCollectionFor(
        bytes32 _merkleRoot,
        address _controller,
        address[] calldata _plugins,
        bytes4[] calldata _selectors
    ) public returns (address vault, address token) {
        token = fNFTImplementation.clone(
            abi.encodePacked(_controller, address(this))
        );
        vault = _deployVault(
            _merkleRoot,
            address(this),
            token,
            _plugins,
            _selectors
        );
    }

    /// @dev Deploys new vault for specified token, sets merkle root, and installs plugins
    /// @param _merkleRoot Hash of merkle root for vault permissions
    /// @param _token Address of FERC1155 contract
    /// @param _plugins Addresses of plugin contracts
    /// @param _selectors List of function selectors
    /// @return vault Address of Proxy contract
    function _deployVault(
        bytes32 _merkleRoot,
        address _owner,
        address _token,
        address[] calldata _plugins,
        bytes4[] calldata _selectors
    ) private returns (address vault) {
        vault = VaultFactory(factory).deployFor(
            _merkleRoot,
            _owner,
            _plugins,
            _selectors
        );
        vaultToToken[vault] = VaultInfo(_token, ++nextId[_token]);
        emit VaultDeployed(vault, _token, nextId[_token]);
    }
}
