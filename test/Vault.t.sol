// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./TestUtil.sol";

contract VaultTest is TestUtil {
    bytes4[] selectors;
    address[] plugins;
    bytes data;

    /// =================
    /// ===== SETUP =====
    /// =================

    function setUp() public {
        setUpContract();

        factory = registry.factory();

        vault = VaultFactory(factory).deploy(bytes32(0), plugins, selectors);

        vm.label(address(this), "VaultTest");
        vm.label(vault, "VaultProxy");
    }

    function setUpTransferExecute(
        address _user,
        address _vault,
        address _erc721,
        uint256 _id
    ) public returns (address, bytes memory) {
        MockERC721(_erc721).mint(_vault, _id);

        data = abi.encodeCall(
            transferTarget.ERC721TransferFrom,
            (_erc721, _vault, _user, _id)
        );

        return (vault, data);
    }

    /// =========================
    /// ===== RECEIVE TOKEN =====
    /// =========================
    function testReceiveEther() public {
        payable(vault).call{value: 1 ether}("");
        assertEq(vault.balance, 1 ether);
    }

    function testReceiveERC721() public {
        MockERC721(erc721).mint(vault, 2);

        assertEq(IERC721(erc721).balanceOf(vault), 1);
    }

    function testReceiveERC1155() public {
        mintERC1155(vault, 1);

        assertEq(IERC1155(erc1155).balanceOf(vault, 1), 10);
    }

    function testDeployCheckSettings() public {
        vault = VaultFactory(factory).deploy(
            bytes32(uint256(1)),
            plugins,
            selectors
        );

        assertEq(Vault(payable(vault)).OWNER(), address(this));
        assertEq(Vault(payable(vault)).MERKLE_ROOT(), bytes32(uint256(1)));
        assertEq(Vault(payable(vault)).FACTORY(), factory);
    }

    /// ===================
    /// ===== EXECUTE =====
    /// ===================
    function testExecute() public {
        vault = VaultFactory(factory).deploy(bytes32(0), plugins, selectors);
        (vault, data) = setUpTransferExecute(address(0xBEEF), vault, erc721, 2);
        Vault(payable(vault)).execute(
            address(transferTarget),
            data,
            new bytes32[](0)
        );
    }

    function testExecuteRevert() public {
        testExecute();
        vm.expectRevert(
            abi.encodeWithSelector(IVault.ExecutionReverted.selector)
        );
        Vault(payable(vault)).execute(
            address(supplyTarget),
            data,
            new bytes32[](0)
        );
    }

    function testBubbleRevert() public {
        testExecute();
        vm.expectRevert(bytes("WRONG_FROM"));
        Vault(payable(vault)).execute(
            address(transferTarget),
            data,
            new bytes32[](0)
        );
    }

    function testExecuteRevertNotAuthorized() public {
        address authorized = address(0xBEEF);
        address executor = address(0xCAFE);
        vault = VaultFactory(factory).deploy(bytes32(0), plugins, selectors);
        (vault, data) = setUpTransferExecute(authorized, vault, erc721, 2);

        vm.startPrank(executor);

        vm.expectRevert(
            abi.encodeWithSelector(
                IVault.NotAuthorized.selector,
                executor,
                address(transferTarget),
                transferTarget.ERC721TransferFrom.selector
            )
        );
        Vault(payable(vault)).execute(
            address(transferTarget),
            data,
            new bytes32[](0)
        );

        vm.stopPrank();
    }

    function testExecuteRevertTargetInvalid() public {
        vault = VaultFactory(factory).deploy(bytes32(0), plugins, selectors);
        (vault, data) = setUpTransferExecute(address(0xBEEF), vault, erc721, 2);
        vm.expectRevert(
            abi.encodeWithSelector(IVault.TargetInvalid.selector, address(0))
        );
        Vault(payable(vault)).execute(address(0), data, new bytes32[](0));
    }

    function testSetPlugins() public {
        vault = VaultFactory(factory).deploy(bytes32(0), plugins, selectors);
        (selectors, plugins) = initializeNFTReceiver();

        Vault(payable(vault)).setPlugins(plugins, selectors);
    }

    function testNotOwner() public {
        vault = VaultFactory(factory).deploy(bytes32(0), plugins, selectors);
        (selectors, plugins) = initializeNFTReceiver();

        vm.startPrank(address(0xBEEF));
        vm.expectRevert(
            abi.encodeWithSelector(
                IVault.NotOwner.selector,
                address(this),
                address(0xBEEF)
            )
        );
        Vault(payable(vault)).setPlugins(plugins, selectors);
        vm.stopPrank();
    }
}
