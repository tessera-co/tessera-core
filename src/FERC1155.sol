// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Clone} from "clones-with-immutable-args/src/Clone.sol";
import {ERC1155} from "@rari-capital/solmate/src/tokens/ERC1155.sol";
import {PermitBase} from "./utils/PermitBase.sol";

import {IFERC1155} from "./interfaces/IFERC1155.sol";
import {INFTReceiver} from "./interfaces/INFTReceiver.sol";

/// @title FERC1155
/// @author Fractional Art
/// @notice An ERC-1155 implementation for Fractions
contract FERC1155 is Clone, ERC1155, IFERC1155, PermitBase {
    /// @notice Address of interface identifier for royalty standard
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// @notice Address that can deploy new vaults and manage metadata for this collection
    address internal _controller;
    /// @notice URI of contract metadata
    string public contractURI;
    /// @notice Mapping of token owner to token operator to token ID type to approval status
    mapping(address => mapping(address => mapping(uint256 => bool)))
        public isApproved;
    /// @notice Mapping of token ID type to metadata contract address
    mapping(uint256 => address) public metadata;
    /// @notice Mapping of token ID type to total supply of tokens
    mapping(uint256 => uint256) public totalSupply;
    /// @notice Mapping of token ID type to royalty beneficiary
    mapping(uint256 => address) private royaltyAddress;
    /// @notice Mapping of token ID type to royalty percentage
    mapping(uint256 => uint256) private royaltyPercent;

    /// @notice Modifier for restricting function calls to the controller account
    modifier onlyController() {
        address controller_ = controller();
        if (msg.sender != controller_)
            revert InvalidSender(controller_, msg.sender);
        _;
    }

    /// @notice Modifier for restricting function calls to the VaultRegistry
    modifier onlyRegistry() {
        address vaultRegistry = VAULT_REGISTRY();
        if (msg.sender != vaultRegistry)
            revert InvalidSender(vaultRegistry, msg.sender);
        _;
    }

    /// @notice Burns fractions for an ID
    /// @param _from Address to burn fraction tokens from
    /// @param _id Token ID to burn
    /// @param _amount Number of tokens to burn
    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) external onlyRegistry {
        _burn(_from, _id, _amount);
        totalSupply[_id] -= _amount;
    }

    /// @notice Hook to emit the URI update when setting the metadata or updating
    /// @param _id Token ID metadata was updated for
    /// @param _uri URI of metadata
    function emitSetURI(uint256 _id, string memory _uri) external {
        if (msg.sender != metadata[_id])
            revert InvalidSender(metadata[_id], msg.sender);
        emit URI(_uri, _id);
    }

    /// @notice Mints new fractions for an ID
    /// @param _to Address to mint fraction tokens to
    /// @param _id Token ID to mint
    /// @param _amount Number of tokens to mint
    /// @param _data Extra calldata to include in the mint
    function mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) external onlyRegistry {
        totalSupply[_id] += _amount;
        _mint(_to, _id, _amount, _data);
    }

    /// @notice Permit function that approves an operator for token type with a valid signature
    /// @param _owner Address of the owner of the token type
    /// @param _operator Address of the spender of the token type
    /// @param _id ID of the token type
    /// @param _approved Approval status for the token type
    /// @param _deadline Expiration of the signature
    /// @param _v The recovery ID (129th byte and chain ID) of the signature used to recover the signer
    /// @param _r The first 64 bytes of the signature
    /// @param _s Bytes 64-128 of the signature
    function permit(
        address _owner,
        address _operator,
        uint256 _id,
        bool _approved,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if (block.timestamp > _deadline)
            revert SignatureExpired(block.timestamp, _deadline);

        // cannot realistically overflow on human timescales
        unchecked {
            bytes32 structHash = _computePermitStructHash(
                _owner,
                _operator,
                _id,
                _approved,
                _deadline
            );

            bytes32 digest = _computeDigest(
                _computeDomainSeparator(),
                structHash
            );

            address signer = ecrecover(digest, _v, _r, _s);

            if (signer == address(0) || signer != _owner)
                revert InvalidSignature(signer, _owner);
        }

        isApproved[_owner][_operator][_id] = _approved;

        emit SingleApproval(_owner, _operator, _id, _approved);
    }

    /// @notice Permit function that approves an operator for all token types with a valid signature
    /// @param _owner Address of the owner of the token type
    /// @param _operator Address of the spender of the token type
    /// @param _approved Approval status for the token type
    /// @param _deadline Expiration of the signature
    /// @param _v The recovery ID (129th byte and chain ID) of the signature used to recover the signer
    /// @param _r The first 64 bytes of the signature
    /// @param _s Bytes 64-128 of the signature
    function permitAll(
        address _owner,
        address _operator,
        bool _approved,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if (block.timestamp > _deadline)
            revert SignatureExpired(block.timestamp, _deadline);

        // cannot realistically overflow on human timescales
        unchecked {
            bytes32 structHash = _computePermitAllStructHash(
                _owner,
                _operator,
                _approved,
                _deadline
            );

            bytes32 digest = _computeDigest(
                _computeDomainSeparator(),
                structHash
            );

            address signer = ecrecover(digest, _v, _r, _s);

            if (signer == address(0) || signer != _owner)
                revert InvalidSignature(signer, _owner);
        }

        isApprovedForAll[_owner][_operator] = _approved;

        emit ApprovalForAll(_owner, _operator, _approved);
    }

    /// @notice Scoped approvals allow us to eliminate some of the risks associated with setting the approval for an entire collection
    /// @param _operator Address of spender account
    /// @param _id ID of the token type
    /// @param _approved Approval status for operator(spender) account
    function setApprovalFor(
        address _operator,
        uint256 _id,
        bool _approved
    ) external {
        isApproved[msg.sender][_operator][_id] = _approved;

        emit SingleApproval(msg.sender, _operator, _id, _approved);
    }

    /// @notice Sets the contract metadata
    /// @param _uri URI of metadata
    function setContractURI(string calldata _uri) external onlyController {
        contractURI = _uri;
    }

    /// @notice Sets the token metadata contract
    /// @param _metadata Address for metadata contract
    /// @param _id Token ID to set the metadata for
    function setMetadata(address _metadata, uint256 _id)
        external
        onlyController
    {
        metadata[_id] = _metadata;
        emit SetMetadata(_metadata, _id);
    }

    /// @notice Sets the token royalties
    /// @param _id Token ID royalties are being updated for
    /// @param _receiver Address to receive royalties
    /// @param _percentage Percentage of royalties on secondary sales (2 decimals of precision)
    function setRoyalties(
        uint256 _id,
        address _receiver,
        uint256 _percentage
    ) external onlyController {
        if (_percentage < 10001) revert InvalidRoyalty(_percentage);
        royaltyAddress[_id] = _receiver;
        royaltyPercent[_id] = _percentage;
        emit SetRoyalty(_receiver, _id, _percentage);
    }

    /// @notice Updates the controller address for the FERC1155 token contract
    /// @param _newController Address of new controlling entity
    function transferController(address _newController)
        external
        onlyController
    {
        if (_newController == address(0)) revert ZeroAddress();
        _controller = _newController;
        emit ControllerTransferred(_newController);
    }

    /// @notice Sets the token royalties
    /// @param _id Token ID royalties are being updated for
    /// @param _salePrice Sale price to calculate the royalty for
    function royaltyInfo(uint256 _id, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = royaltyAddress[_id];
        royaltyAmount = (_salePrice * royaltyPercent[_id]) / 10000;
    }

    /// @notice ERC165 implementation
    /// @param interfaceId ERC165 Interface ID
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            interfaceId == _INTERFACE_ID_ERC2981 ||
            super.supportsInterface(interfaceId); // ERC165 Interface ID for ERC2981
    }

    /// @notice Transfer an amount of a token type between two accounts
    /// @param _from Source address for an amount of tokens
    /// @param _to Destination address for an amount of tokens
    /// @param _id ID of the token type
    /// @param _amount The amount of tokens being transferred
    /// @param _data Additional calldata
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public override(ERC1155, IFERC1155) {
        require(
            msg.sender == _from ||
                isApprovedForAll[_from][msg.sender] ||
                isApproved[_from][msg.sender][_id],
            "NOT_AUTHORIZED"
        );

        balanceOf[_from][_id] -= _amount;
        balanceOf[_to][_id] += _amount;

        emit TransferSingle(msg.sender, _from, _to, _id, _amount);

        require(
            _to.code.length == 0
                ? _to != address(0)
                : INFTReceiver(_to).onERC1155Received(
                    msg.sender,
                    _from,
                    _id,
                    _amount,
                    _data
                ) == INFTReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /// @notice Getter for URI of a token type
    /// @param _id ID of the token type
    function uri(uint256 _id)
        public
        view
        override(ERC1155, IFERC1155)
        returns (string memory)
    {
        require(metadata[_id] != address(0), "NO METADATA");
        return IFERC1155(metadata[_id]).uri(_id);
    }

    /// @notice Getter for controller account
    function controller() public view returns (address controllerAddress) {
        _controller == address(0)
            ? controllerAddress = INITIAL_CONTROLLER()
            : controllerAddress = _controller;
    }

    /// @notice Getter for initial controller account immutable argument stored in calldata
    function INITIAL_CONTROLLER() public pure returns (address) {
        return _getArgAddress(0);
    }

    /// @notice VaultRegistry address that is allowed to call mint() and burn()
    function VAULT_REGISTRY() public pure returns (address) {
        return _getArgAddress(20);
    }
}
