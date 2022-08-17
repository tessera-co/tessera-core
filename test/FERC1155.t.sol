// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./TestUtil.sol";

contract FERC1155Test is TestUtil {
    string tokenURI = "token uri";
    string contractURI = "contract uri";
    event URI(string value, uint256 indexed id);

    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        setUpContract();
        alice = setUpUser(111, 1);
        bob = setUpUser(222, 2);
        setUpCreateFor(alice);
        setUpMetadata(alice);

        vm.label(address(this), "FERC1155Test");
        vm.label(alice.addr, "Alice");
        vm.label(bob.addr, "Bob");
    }

    /// ============================
    /// ===== SET CONTRACT URI =====
    /// ============================
    function testSetContractURI() public {
        fERC1155.setContractURI(contractURI);
        assertEq(fERC1155.contractURI(), contractURI);
    }

    function testSetContractURIRevertInvalidSender() public {
        (token, ) = registry.vaultToToken(vault);
        setUpFERC1155(bob, token);
        vm.expectRevert(
            abi.encodeWithSelector(
                IFERC1155.InvalidSender.selector,
                fERC1155.controller(),
                bob.addr
            )
        );

        fERC1155.setContractURI(contractURI);
    }

    /// ========================
    /// ===== SET METADATA =====
    /// ========================
    function testSetMetadata() public {
        fERC1155.setMetadata(address(metadata), tokenId);
        assertEq(address(metadata), fERC1155.metadata(tokenId));
    }

    /// ===================
    /// ===== SET URI =====
    /// ===================
    function testSetURI() public {
        fERC1155.setMetadata(address(metadata), tokenId);

        vm.expectEmit(true, true, false, true);
        emit URI(tokenURI, tokenId);

        vm.startPrank(alice.addr);
        metadata.setURI(tokenId, tokenURI);
        vm.stopPrank();
    }

    function testSetURIRevertInvalidSender() public {
        fERC1155.setMetadata(address(metadata), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                IFERC1155.InvalidSender.selector,
                fERC1155.controller(),
                address(this)
            )
        );

        metadata.setURI(tokenId, tokenURI);
    }

    /// ======================
    /// ===== PERMIT ALL =====
    /// ======================
    function testPermitAll(bool _approved, uint256 _deadline) public {
        setUpPermit(alice, _approved, _deadline);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            bob.addr,
            approved,
            nonce,
            deadline
        );

        fERC1155.permitAll(alice.addr, bob.addr, approved, deadline, v, r, s);
    }

    function testPermitAllApproval() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            bob.addr,
            approved,
            nonce,
            deadline
        );

        fERC1155.permitAll(alice.addr, bob.addr, approved, deadline, v, r, s);
        assertTrue(fERC1155.isApprovedForAll(alice.addr, bob.addr));
    }

    function testPermitAllRemoval() public {
        testPermitAllApproval();
        approved = false;
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            bob.addr,
            approved,
            nonce + 1,
            deadline
        );

        fERC1155.permitAll(alice.addr, bob.addr, approved, deadline, v, r, s);
        assertTrue(!fERC1155.isApprovedForAll(alice.addr, bob.addr));
    }

    function testFailPermitAllApproved() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            bob.addr,
            !approved,
            nonce,
            deadline
        );

        fERC1155.permitAll(alice.addr, bob.addr, approved, deadline, v, r, s);
    }

    function testFailPermitAllNonce() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            bob.addr,
            approved,
            nonce + 1,
            deadline
        );

        fERC1155.permitAll(alice.addr, bob.addr, approved, deadline, v, r, s);
    }

    function testFailPermitAllDeadline() public {
        setUpPermit(alice, true, 1);
        vm.warp(deadline + 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            bob.addr,
            approved,
            nonce,
            deadline
        );

        fERC1155.permitAll(alice.addr, bob.addr, approved, deadline, v, r, s);
    }

    /// =========================
    /// ===== SINGLE PERMIT =====
    /// =========================
    function testSinglePermit(bool _approved, uint256 _deadline) public {
        setUpPermit(alice, _approved, _deadline);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            bob.addr,
            approved,
            nonce,
            deadline
        );

        fERC1155.permit(
            alice.addr,
            bob.addr,
            tokenId,
            approved,
            deadline,
            v,
            r,
            s
        );
    }

    function testSinglePermitApproval() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            bob.addr,
            approved,
            nonce,
            deadline
        );

        fERC1155.permit(
            alice.addr,
            bob.addr,
            tokenId,
            approved,
            deadline,
            v,
            r,
            s
        );

        assertTrue(fERC1155.isApproved(alice.addr, bob.addr, tokenId));
    }

    function testSinglePermitRemoval() public {
        testSinglePermitApproval();
        approved = false;
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            bob.addr,
            approved,
            nonce + 1,
            deadline
        );

        fERC1155.permit(
            alice.addr,
            bob.addr,
            tokenId,
            approved,
            deadline,
            v,
            r,
            s
        );

        assertTrue(!fERC1155.isApproved(alice.addr, bob.addr, tokenId));
    }

    function testFailSinglePermitApproved() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            bob.addr,
            !approved,
            nonce,
            deadline
        );

        fERC1155.permit(
            alice.addr,
            bob.addr,
            tokenId,
            approved,
            deadline,
            v,
            r,
            s
        );
    }

    function testFailSinglePermitNonce() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            bob.addr,
            approved,
            nonce + 1,
            deadline
        );

        fERC1155.permit(
            alice.addr,
            bob.addr,
            tokenId,
            approved,
            deadline,
            v,
            r,
            s
        );
    }

    function testFailSinglePermitDeadline() public {
        setUpPermit(alice, true, 1);
        vm.warp(deadline + 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            bob.addr,
            approved,
            nonce,
            deadline
        );

        fERC1155.permit(
            alice.addr,
            bob.addr,
            tokenId,
            approved,
            deadline,
            v,
            r,
            s
        );
    }

    function testInterfaceSupport() public {
        assertTrue(fERC1155.supportsInterface(0x2a55205a));
        assertTrue(fERC1155.supportsInterface(0xd9b67a26));
        assertTrue(fERC1155.supportsInterface(0x01ffc9a7));
        assertTrue(fERC1155.supportsInterface(0x0e89341c));
    }
}
