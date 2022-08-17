// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IModule} from "./IModule.sol";
import {Permission} from "./IVaultRegistry.sol";

/// @dev Possible states that a buyout auction may have
enum State {
    INACTIVE,
    LIVE,
    SUCCESS
}

/// @dev Auction information
struct Auction {
    // Time of when buyout begins
    uint256 startTime;
    // Address of proposer creating buyout
    address proposer;
    // Enum state of the buyout auction
    State state;
    // Price of fractional tokens
    uint256 fractionPrice;
    // Balance of ether in buyout pool
    uint256 ethBalance;
    // Total supply recorded before a buyout started
    uint256 lastTotalSupply;
}

/// @dev Interface for Buyout module contract
interface IBuyout is IModule {
    /// @dev Emitted when the payment amount does not equal the fractional price
    error InvalidPayment();
    /// @dev Emitted when the buyout state is invalid
    error InvalidState(State _required, State _current);
    /// @dev Emitted when the caller has no balance of fractional tokens
    error NoFractions();
    /// @dev Emitted when the caller is not the winner of an auction
    error NotWinner();
    /// @dev Emitted when the address is not a registered vault
    error NotVault(address _vault);
    /// @dev Emitted when the time has expired for selling and buying fractions
    error TimeExpired(uint256 _current, uint256 _deadline);
    /// @dev Emitted when the buyout auction is still active
    error TimeNotElapsed(uint256 _current, uint256 _deadline);
    /// @dev Emitted when ether deposit amount for starting a buyout is zero
    error ZeroDeposit();

    /// @dev Event log for starting a buyout
    /// @param _vault Address of the vault
    /// @param _proposer Address that created the buyout
    /// @param _startTime Timestamp of when buyout was created
    /// @param _buyoutPrice Price of buyout pool in ether
    /// @param _fractionPrice Price of fractional tokens
    event Start(
        address indexed _vault,
        address indexed _proposer,
        uint256 _startTime,
        uint256 _buyoutPrice,
        uint256 _fractionPrice
    );
    /// @dev Event log for selling fractional tokens into the buyout pool
    /// @param _seller Address selling fractions
    /// @param _amount Transfer amount being sold
    event SellFractions(address indexed _seller, uint256 _amount);
    /// @dev Event log for buying fractional tokens from the buyout pool
    /// @param _buyer Address buying fractions
    /// @param _amount Transfer amount being bought
    event BuyFractions(address indexed _buyer, uint256 _amount);
    /// @dev Event log for ending an active buyout
    /// @param _vault Address of the vault
    /// @param _state Enum state of auction
    /// @param _proposer Address that created the buyout
    event End(address _vault, State _state, address indexed _proposer);
    /// @dev Event log for cashing out ether for fractions from a successful buyout
    /// @param _vault Address of the vault
    /// @param _casher Address cashing out of buyout
    /// @param _amount Transfer amount of ether
    event Cash(address _vault, address indexed _casher, uint256 _amount);
    /// @dev Event log for redeeming the underlying vault assets from an inactive buyout
    /// @param _vault Address of the vault
    /// @param _redeemer Address redeeming underlying assets
    event Redeem(address _vault, address indexed _redeemer);

    function PROPOSAL_PERIOD() external view returns (uint256);

    function REJECTION_PERIOD() external view returns (uint256);

    function batchWithdrawERC1155(
        address _vault,
        address _token,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes32[] memory _erc1155BatchTransferProof
    ) external;

    function buyFractions(address _vault, uint256 _amount) external payable;

    function buyoutInfo(address)
        external
        view
        returns (
            uint256 startTime,
            address proposer,
            State state,
            uint256 fractionPrice,
            uint256 ethBalance,
            uint256 lastTotalSupply
        );

    function cash(address _vault, bytes32[] memory _burnProof) external;

    function end(address _vault, bytes32[] memory _burnProof) external;

    function getLeafNodes() external view returns (bytes32[] memory nodes);

    function getPermissions()
        external
        view
        returns (Permission[] memory permissions);

    function redeem(address _vault, bytes32[] memory _burnProof) external;

    function registry() external view returns (address);

    function sellFractions(address _vault, uint256 _amount) external;

    function start(address _vault, uint256 _amount) external payable;

    function supply() external view returns (address);

    function transfer() external view returns (address);

    function withdrawERC20(
        address _vault,
        address _token,
        address _to,
        uint256 _value,
        bytes32[] memory _erc20TransferProof
    ) external;

    function withdrawERC721(
        address _vault,
        address _token,
        address _to,
        uint256 _tokenId,
        bytes32[] memory _erc721TransferProof
    ) external;

    function withdrawERC1155(
        address _vault,
        address _token,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes32[] memory _erc1155TransferProof
    ) external;
}
