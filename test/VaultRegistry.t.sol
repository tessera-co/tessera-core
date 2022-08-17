// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./TestUtil.sol";

contract VaultRegistryTest is TestUtil {
    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        setUpContract();
        alice = setUpUser(111, 1);
        bob = setUpUser(222, 2);
        setUpCreateFor(alice);
        (nftReceiverSelectors, nftReceiverPlugins) = initializeNFTReceiver();

        vm.label(address(this), "VaultRegistryTest");
        vm.label(alice.addr, "Alice");
        vm.label(bob.addr, "Bob");
    }

    /// ========================
    /// ===== CREATE VAULT =====
    /// ========================
    function testCreate() public {
        vault = alice.registry.create(
            merkleRoot,
            nftReceiverPlugins,
            nftReceiverSelectors
        );
        token = registry.fNFT();
        setUpFERC1155(alice, token);

        assertEq(IVault(vault).OWNER(), address(registry));
        assertEq(fERC1155.controller(), address(this));
    }

    function testCreateFor() public {
        vault = alice.registry.createFor(
            merkleRoot,
            alice.addr,
            nftReceiverPlugins,
            nftReceiverSelectors
        );
        token = registry.fNFT();
        setUpFERC1155(alice, token);

        assertEq(IVault(vault).OWNER(), alice.addr);
        assertEq(fERC1155.controller(), address(this));
    }

    function testCreateCollection() public {
        (vault, token) = alice.registry.createCollection(
            merkleRoot,
            nftReceiverPlugins,
            nftReceiverSelectors
        );

        assertEq(IVault(vault).OWNER(), address(registry));
        assertEq(IFERC1155(token).controller(), alice.addr);
    }

    function testCreateCollectionFor() public {
        (vault, token) = alice.registry.createCollectionFor(
            merkleRoot,
            bob.addr,
            nftReceiverPlugins,
            nftReceiverSelectors
        );

        assertEq(IVault(vault).OWNER(), address(registry));
        assertEq(IFERC1155(token).controller(), bob.addr);
    }

    function testCreateInCollection() public {
        testCreateCollectionFor();

        vault = bob.registry.createInCollection(
            merkleRoot,
            token,
            nftReceiverPlugins,
            nftReceiverSelectors
        );

        assertEq(IVault(vault).OWNER(), address(registry));
        assertEq(IFERC1155(token).controller(), bob.addr);
    }

    function testCreateInCollectionRevertNotController() public {
        token = registry.fNFT();
        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultRegistry.InvalidController.selector,
                address(this),
                bob.addr
            )
        );
        bob.registry.createInCollection(
            merkleRoot,
            token,
            nftReceiverPlugins,
            nftReceiverSelectors
        );
    }
}
