// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./TestUtil.sol";
import {MockPermitter} from "../src/mocks/MockPermitter.sol";

contract SelfPermitTest is TestUtil {
    MockPermitter permitter;

    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        setUpContract();
        alice = setUpUser(111, 1);
        bob = setUpUser(222, 2);
        setUpCreateFor(alice);

        permitter = new MockPermitter();

        vm.label(address(this), "FERC1155Test");
        vm.label(alice.addr, "Alice");
        vm.label(bob.addr, "Bob");
    }

    /// ======================
    /// ===== PERMIT ALL =====
    /// ======================
    function testPermitAll(bool _approved, uint256 _deadline) public {
        setUpPermit(alice, _approved, _deadline);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            address(permitter),
            approved,
            nonce,
            deadline
        );
        vm.startPrank(alice.addr);
        permitter.selfPermitAll(token, approved, deadline, v, r, s);
        vm.stopPrank();
    }

    function testPermitAllApproval() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            address(permitter),
            approved,
            nonce,
            deadline
        );
        vm.startPrank(alice.addr);
        permitter.selfPermitAll(token, approved, deadline, v, r, s);
        vm.stopPrank();

        assertTrue(fERC1155.isApprovedForAll(alice.addr, address(permitter)));
    }

    function testPermitAllRemoval() public {
        testPermitAllApproval();
        approved = false;
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            address(permitter),
            approved,
            nonce + 1,
            deadline
        );
        vm.startPrank(alice.addr);
        permitter.selfPermitAll(token, approved, deadline, v, r, s);
        vm.stopPrank();

        assertTrue(!fERC1155.isApprovedForAll(alice.addr, address(permitter)));
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
        vm.startPrank(alice.addr);
        permitter.selfPermitAll(token, approved, deadline, v, r, s);
        vm.stopPrank();
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
        vm.startPrank(alice.addr);
        permitter.selfPermitAll(token, approved, deadline, v, r, s);
        vm.stopPrank();
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
        vm.startPrank(alice.addr);
        permitter.selfPermitAll(token, approved, deadline, v, r, s);
        vm.stopPrank();
    }

    /// =========================
    /// ===== SINGLE PERMIT =====
    /// =========================
    function testSinglePermit(bool _approved, uint256 _deadline) public {
        setUpPermit(alice, _approved, _deadline);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            address(permitter),
            approved,
            nonce,
            deadline
        );
        vm.startPrank(alice.addr);
        permitter.selfPermit(token, tokenId, approved, deadline, v, r, s);
        vm.stopPrank();
    }

    function testSinglePermitApproval() public {
        setUpPermit(alice, true, 1);
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            address(permitter),
            approved,
            nonce,
            deadline
        );
        vm.startPrank(alice.addr);
        permitter.selfPermit(token, tokenId, approved, deadline, v, r, s);
        vm.stopPrank();
        assertTrue(
            fERC1155.isApproved(alice.addr, address(permitter), tokenId)
        );
    }

    function testSinglePermitRemoval() public {
        testSinglePermitApproval();
        approved = false;
        (uint8 v, bytes32 r, bytes32 s) = signPermit(
            alice,
            address(permitter),
            approved,
            nonce + 1,
            deadline
        );
        vm.startPrank(alice.addr);
        permitter.selfPermit(token, tokenId, approved, deadline, v, r, s);
        vm.stopPrank();
        assertTrue(
            !fERC1155.isApproved(alice.addr, address(permitter), tokenId)
        );
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
        vm.startPrank(alice.addr);
        permitter.selfPermit(token, tokenId, approved, deadline, v, r, s);
        vm.stopPrank();
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

        vm.startPrank(alice.addr);
        permitter.selfPermit(token, tokenId, approved, deadline, v, r, s);
        vm.stopPrank();
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
        vm.startPrank(alice.addr);
        permitter.selfPermit(token, tokenId, approved, deadline, v, r, s);
        vm.stopPrank();
    }
}
