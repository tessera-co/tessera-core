// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Multicall} from "../utils/Multicall.sol";
import {NFTReceiver} from "../utils/NFTReceiver.sol";
import {SafeSend} from "../utils/SafeSend.sol";
import {SelfPermit} from "../utils/SelfPermit.sol";

import {IBuyout, Auction, State} from "../interfaces/IBuyout.sol";
import {IERC1155} from "../interfaces/IERC1155.sol";
import {IFERC1155} from "../interfaces/IFERC1155.sol";
import {ISupply} from "../interfaces/ISupply.sol";
import {ITransfer} from "../interfaces/ITransfer.sol";
import {IVault} from "../interfaces/IVault.sol";
import {IVaultRegistry, Permission} from "../interfaces/IVaultRegistry.sol";

/// @title Buyout
/// @author Fractional Art
/// @notice Module contract for vaults to hold buyout pools
/// - A fractional owner starts an auction for a vault by depositing any amount of ether and fractional tokens into a pool.
/// - During the proposal period (2 days) users can sell their fractional tokens into the pool for ether.
/// - During the rejection period (4 days) users can buy fractional tokens from the pool with ether.
/// - If a pool has more than 50% of the total supply after 4 days, the buyout is successful and the proposer
///   gains access to withdraw the underlying assets (ERC-20, ERC-721, and ERC-1155 tokens) from the vault.
///   Otherwise the buyout is considered unsuccessful and a new one may then begin.
/// - NOTE: A vault may only have one active buyout at any given time.
/// - fractionPrice = ethAmount / (totalSupply - fractionAmount)
/// - buyoutPrice = fractionAmount * fractionPrice + ethAmount
contract Buyout is IBuyout, Multicall, NFTReceiver, SafeSend, SelfPermit {
    /// @notice Address of VaultRegistry contract
    address public registry;
    /// @notice Address of Supply target contract
    address public supply;
    /// @notice Address of Transfer target contract
    address public transfer;
    /// @notice Time length of the proposal period
    uint256 public constant PROPOSAL_PERIOD = 2 days;
    /// @notice Time length of the rejection period
    uint256 public constant REJECTION_PERIOD = 4 days;
    /// @notice Mapping of vault address to auction struct
    mapping(address => Auction) public buyoutInfo;

    /// @notice Initializes registry, supply, and transfer contracts
    constructor(
        address _registry,
        address _supply,
        address _transfer
    ) {
        registry = _registry;
        supply = _supply;
        transfer = _transfer;
    }

    /// @dev Callback for receiving ether when the calldata is empty
    receive() external payable {}

    /// @notice Starts the auction for a buyout pool
    /// @param _vault Address of the vault
    /// @param _amount Number of fractional tokens deposited into pool
    function start(address _vault, uint256 _amount) external payable {
        // Reverts if ether deposit amount is zero
        if (msg.value == 0) revert ZeroDeposit();
        // Reverts if address is not a registered vault
        (address token, uint256 id) = IVaultRegistry(registry).vaultToToken(
            _vault
        );
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not inactive
        (, , State current, , , ) = this.buyoutInfo(_vault);
        State required = State.INACTIVE;
        if (current != required) revert InvalidState(required, current);

        // Gets total supply of fractional tokens for the vault
        uint256 totalSupply = IVaultRegistry(registry).totalSupply(_vault);
        // Transfers fractional tokens into the buyout pool
        IERC1155(token).safeTransferFrom(
            msg.sender,
            address(this),
            id,
            _amount,
            ""
        );

        // Calculates price of buyout and fractions
        // @dev Reverts with division error if called with total supply of tokens
        uint256 fractionPrice = msg.value / (totalSupply - _amount);
        uint256 buyoutPrice = _amount * fractionPrice + msg.value;

        // Sets info mapping of the vault address to auction struct
        buyoutInfo[_vault] = Auction(
            block.timestamp,
            msg.sender,
            State.LIVE,
            fractionPrice,
            msg.value,
            totalSupply
        );
        // Emits event for starting auction
        emit Start(
            _vault,
            msg.sender,
            block.timestamp,
            buyoutPrice,
            fractionPrice
        );
    }

    /// @notice Sells fractional tokens in exchange for ether from a pool
    /// @param _vault Address of the vault
    /// @param _amount Transfer amount of fractions
    function sellFractions(address _vault, uint256 _amount) external {
        // Reverts if address is not a registered vault
        (address token, uint256 id) = IVaultRegistry(registry).vaultToToken(
            _vault
        );
        if (id == 0) revert NotVault(_vault);
        (uint256 startTime, , State current, uint256 fractionPrice, , ) = this
            .buyoutInfo(_vault);
        // Reverts if auction state is not live
        State required = State.LIVE;
        if (current != required) revert InvalidState(required, current);
        // Reverts if current time is greater than end time of proposal period
        uint256 endTime = startTime + PROPOSAL_PERIOD;
        if (block.timestamp > endTime)
            revert TimeExpired(block.timestamp, endTime);

        // Transfers fractional tokens to pool from caller
        IERC1155(token).safeTransferFrom(
            msg.sender,
            address(this),
            id,
            _amount,
            ""
        );

        // Updates ether balance of pool
        uint256 ethAmount = fractionPrice * _amount;
        buyoutInfo[_vault].ethBalance -= ethAmount;
        // Transfers ether amount to caller
        _sendEthOrWeth(msg.sender, ethAmount);
        // Emits event for selling fractions into pool
        emit SellFractions(msg.sender, _amount);
    }

    /// @notice Buys fractional tokens in exchange for ether from a pool
    /// @param _vault Address of the vault
    /// @param _amount Transfer amount of fractions
    function buyFractions(address _vault, uint256 _amount) external payable {
        // Reverts if address is not a registered vault
        (address token, uint256 id) = IVaultRegistry(registry).vaultToToken(
            _vault
        );
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not live
        (
            uint256 startTime,
            address proposer,
            State current,
            uint256 fractionPrice,
            ,

        ) = this.buyoutInfo(_vault);
        State required = State.LIVE;
        if (current != required) revert InvalidState(required, current);
        // Reverts if current time is greater than end time of rejection period
        uint256 endTime = startTime + REJECTION_PERIOD;
        if (block.timestamp > endTime)
            revert TimeExpired(block.timestamp, endTime);
        // Reverts if payment amount does not equal price of fractional amount
        if (msg.value != fractionPrice * _amount) revert InvalidPayment();

        uint256 tokenBalance = IERC1155(token).balanceOf(address(this), id);
        // Transfers fractional tokens to caller
        IERC1155(token).safeTransferFrom(
            address(this),
            msg.sender,
            id,
            _amount,
            ""
        );
        // Updates ether balance of pool
        buyoutInfo[_vault].ethBalance += msg.value;
        // Emits event for buying fractions from pool
        emit BuyFractions(msg.sender, _amount);

        // Terminate live pool if all fractions have been bought out
        if (_amount == tokenBalance) {
            _terminateBuyout(_vault, proposer, buyoutInfo[_vault].ethBalance);
        }
    }

    /// @notice Ends the auction for a live buyout pool
    /// @param _vault Address of the vault
    /// @param _burnProof Merkle proof for burning fractional tokens
    function end(address _vault, bytes32[] calldata _burnProof) external {
        // Reverts if address is not a registered vault
        (address token, uint256 id) = IVaultRegistry(registry).vaultToToken(
            _vault
        );
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not live
        (
            uint256 startTime,
            address proposer,
            State current,
            ,
            uint256 ethBalance,
            uint256 totalSupply
        ) = this.buyoutInfo(_vault);
        // Creates local scope to avoid stack too deep
        {
            State required = State.LIVE;
            if (current != required) revert InvalidState(required, current);
            // Reverts if current time is less than or equal to end time of auction
            uint256 endTime = startTime + REJECTION_PERIOD;
            if (block.timestamp <= endTime)
                revert TimeNotElapsed(block.timestamp, endTime);
        }

        uint256 tokenBalance = IERC1155(token).balanceOf(address(this), id);
        // Checks if totalSupply of auction pool is greater than 50% for a successful buyout
        // prettier-ignore
        if (tokenBalance > totalSupply >> 1) {
            // Initializes vault transaction
            bytes memory data = abi.encodeCall(
                ISupply.burn,
                (address(this), tokenBalance)
            );
            // Executes burn of fractional tokens from pool
            IVault(payable(_vault)).execute(supply, data, _burnProof);
            // Sets buyout state to successful
            buyoutInfo[_vault].state = State.SUCCESS;
        } else {
            // Terminates live pool and transfers eth to proposer
            _terminateBuyout(_vault, proposer, ethBalance);

            // Transfers fractions and ether back to proposer of the buyout pool
            IERC1155(token).safeTransferFrom(
                address(this),
                proposer,
                id,
                tokenBalance,
                ""
            );
        }

        // Emits event of buyout state after ending an auction
        emit End(_vault, buyoutInfo[_vault].state, proposer);
    }

    /// @notice Cashes out proceeds from a successful buyout
    /// @param _vault Address of the vault
    /// @param _burnProof Merkle proof for burning fractional tokens
    function cash(address _vault, bytes32[] calldata _burnProof) external {
        // Reverts if address is not a registered vault
        (address token, uint256 id) = IVaultRegistry(registry).vaultToToken(
            _vault
        );
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not successful
        (, , State current, , uint256 ethBalance, ) = this.buyoutInfo(_vault);
        State required = State.SUCCESS;
        if (current != required) revert InvalidState(required, current);
        // Reverts if caller has a balance of zero fractional tokens
        uint256 tokenBalance = IERC1155(token).balanceOf(msg.sender, id);
        if (tokenBalance == 0) revert NoFractions();

        // Initializes vault transaction
        bytes memory data = abi.encodeCall(
            ISupply.burn,
            (msg.sender, tokenBalance)
        );
        // Executes burn of fractional tokens from caller
        IVault(payable(_vault)).execute(supply, data, _burnProof);

        // Transfers buyout share amount to caller based on total supply
        uint256 totalSupply = IFERC1155(token).totalSupply(id);
        uint256 buyoutShare = (tokenBalance * ethBalance) /
            (totalSupply + tokenBalance);
        _sendEthOrWeth(msg.sender, buyoutShare);

        // Emits event for cashing out of buyout pool
        emit Cash(_vault, msg.sender, buyoutShare);
    }

    /// @notice Terminates a vault with an inactive buyout
    /// @param _vault Address of the vault
    /// @param _burnProof Merkle proof for burning fractional tokens
    function redeem(address _vault, bytes32[] calldata _burnProof) external {
        // Reverts if address is not a registered vault
        (address token, uint256 id) = IVaultRegistry(registry).vaultToToken(
            _vault
        );
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not inactive
        (, , State current, , , ) = this.buyoutInfo(_vault);
        State required = State.INACTIVE;
        if (current != required) revert InvalidState(required, current);

        // Initializes vault transaction
        uint256 totalSupply = IFERC1155(token).totalSupply(id);
        bytes memory data = abi.encodeCall(
            ISupply.burn,
            (msg.sender, totalSupply)
        );
        // Executes burn of fractional tokens from caller
        IVault(payable(_vault)).execute(supply, data, _burnProof);

        // Sets buyout state to successful and proposer to caller
        (buyoutInfo[_vault].state, buyoutInfo[_vault].proposer) = (
            State.SUCCESS,
            msg.sender
        );
        // Emits event for redeem underlying assets from the vault
        emit Redeem(_vault, msg.sender);
    }

    /// @notice Withdraws an ERC-20 token from a vault
    /// @param _vault Address of the vault
    /// @param _token Address of the token
    /// @param _to Address of the receiver
    /// @param _value Transfer amount
    /// @param _erc20TransferProof Merkle proof for transferring an ERC-20 token
    function withdrawERC20(
        address _vault,
        address _token,
        address _to,
        uint256 _value,
        bytes32[] calldata _erc20TransferProof
    ) external {
        // Reverts if address is not a registered vault
        (, uint256 id) = IVaultRegistry(registry).vaultToToken(_vault);
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not successful
        (, address proposer, State current, , , ) = this.buyoutInfo(_vault);
        State required = State.SUCCESS;
        if (current != required) revert InvalidState(required, current);
        // Reverts if caller is not the auction winner
        if (msg.sender != proposer) revert NotWinner();

        // Initializes vault transaction
        bytes memory data = abi.encodeCall(
            ITransfer.ERC20Transfer,
            (_token, _to, _value)
        );
        // Executes transfer of ERC721 token to caller
        IVault(payable(_vault)).execute(transfer, data, _erc20TransferProof);
    }

    /// @notice Withdraws an ERC-721 token from a vault
    /// @param _vault Address of the vault
    /// @param _token Address of the token
    /// @param _to Address of the receiver
    /// @param _tokenId ID of the token
    /// @param _erc721TransferProof Merkle proof for transferring an ERC-721 token
    function withdrawERC721(
        address _vault,
        address _token,
        address _to,
        uint256 _tokenId,
        bytes32[] calldata _erc721TransferProof
    ) external {
        // Reverts if address is not a registered vault
        (, uint256 id) = IVaultRegistry(registry).vaultToToken(_vault);
        if (id == 0) revert NotVault(_vault);
        // Reverts if auction state is not successful
        (, address proposer, State current, , , ) = this.buyoutInfo(_vault);
        State required = State.SUCCESS;
        if (current != required) revert InvalidState(required, current);
        // Reverts if caller is not the auction winner
        if (msg.sender != proposer) revert NotWinner();

        // Initializes vault transaction
        bytes memory data = abi.encodeCall(
            ITransfer.ERC721TransferFrom,
            (_token, _vault, _to, _tokenId)
        );
        // Executes transfer of ERC721 token to caller
        IVault(payable(_vault)).execute(transfer, data, _erc721TransferProof);
    }

    /// @notice Withdraws an ERC-1155 token from a vault
    /// @param _vault Address of the vault
    /// @param _token Address of the token
    /// @param _to Address of the receiver
    /// @param _id ID of the token type
    /// @param _value Transfer amount
    /// @param _erc1155TransferProof Merkle proof for transferring an ERC-1155 token
    function withdrawERC1155(
        address _vault,
        address _token,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes32[] calldata _erc1155TransferProof
    ) external {
        // Creates local scope to avoid stack too deep
        {
            // Reverts if address is not a registered vault
            (, uint256 id) = IVaultRegistry(registry).vaultToToken(_vault);
            if (id == 0) revert NotVault(_vault);
            // Reverts if auction state is not successful
            (, address proposer, State current, , , ) = this.buyoutInfo(_vault);
            State required = State.SUCCESS;
            if (current != required) revert InvalidState(required, current);
            // Reverts if caller is not the auction winner
            if (msg.sender != proposer) revert NotWinner();
        }

        // Initializes vault transaction
        bytes memory data = abi.encodeCall(
            ITransfer.ERC1155TransferFrom,
            (_token, _vault, _to, _id, _value)
        );
        // Executes transfer of ERC1155 token to caller
        IVault(payable(_vault)).execute(transfer, data, _erc1155TransferProof);
    }

    /// @notice Batch withdraws ERC-1155 tokens from a vault
    /// @param _vault Address of the vault
    /// @param _token Address of the token
    /// @param _to Address of the receiver
    /// @param _ids IDs of each token type
    /// @param _values Transfer amounts per token type
    /// @param _erc1155BatchTransferProof Merkle proof for transferring multiple ERC-1155 tokens
    function batchWithdrawERC1155(
        address _vault,
        address _token,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes32[] calldata _erc1155BatchTransferProof
    ) external {
        // Creates local scope to avoid stack too deep
        {
            // Reverts if address is not a registered vault
            (, uint256 id) = IVaultRegistry(registry).vaultToToken(_vault);
            if (id == 0) revert NotVault(_vault);
            // Reverts if auction state is not successful
            (, address proposer, State current, , , ) = this.buyoutInfo(_vault);
            State required = State.SUCCESS;
            if (current != required) revert InvalidState(required, current);
            // Reverts if caller is not the auction winner
            if (msg.sender != proposer) revert NotWinner();
        }

        // Initializes vault transaction
        bytes memory data = abi.encodeCall(
            ITransfer.ERC1155BatchTransferFrom,
            (_token, _vault, _to, _ids, _values)
        );
        // Executes batch transfer of multiple ERC1155 tokens to caller
        IVault(payable(_vault)).execute(
            transfer,
            data,
            _erc1155BatchTransferProof
        );
    }

    /// @notice Gets the list of leaf nodes used to generate a merkle tree
    /// @dev Leaf nodes are hashed permissions of the merkle tree
    /// @return nodes Hashes of leaf nodes
    function getLeafNodes() external view returns (bytes32[] memory nodes) {
        nodes = new bytes32[](5);
        // Gets list of permissions from this module
        Permission[] memory permissions = getPermissions();
        for (uint256 i; i < permissions.length; ) {
            // Hashes permission into leaf node
            nodes[i] = keccak256(abi.encode(permissions[i]));
            // Can't overflow since loop is a fixed size
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Gets the list of permissions installed on a vault
    /// @dev Permissions consist of a module contract, target contract, and function selector
    /// @return permissions List of vault permissions
    function getPermissions()
        public
        view
        returns (Permission[] memory permissions)
    {
        permissions = new Permission[](5);
        // Burn function selector from supply contract
        permissions[0] = Permission(
            address(this),
            supply,
            ISupply(supply).burn.selector
        );
        // ERC20Transfer function selector from transfer contract
        permissions[1] = Permission(
            address(this),
            transfer,
            ITransfer(transfer).ERC20Transfer.selector
        );
        // ERC721TransferFrom function selector from transfer contract
        permissions[2] = Permission(
            address(this),
            transfer,
            ITransfer(transfer).ERC721TransferFrom.selector
        );
        // ERC1155TransferFrom function selector from transfer contract
        permissions[3] = Permission(
            address(this),
            transfer,
            ITransfer(transfer).ERC1155TransferFrom.selector
        );
        // ERC1155BatchTransferFrom function selector from transfer contract
        permissions[4] = Permission(
            address(this),
            transfer,
            ITransfer(transfer).ERC1155BatchTransferFrom.selector
        );
    }

    /// @dev Terminates live pool and transfers remaining balance
    /// @param _vault Address of the vault
    /// @param _to Address of the proposer
    /// @param _ethAmount Transfer amount
    function _terminateBuyout(
        address _vault,
        address _to,
        uint256 _ethAmount
    ) internal {
        delete buyoutInfo[_vault];

        _sendEthOrWeth(_to, _ethAmount);
    }
}
