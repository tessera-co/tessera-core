// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./TestUtil.sol";

contract BuyoutTest is TestUtil {
    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        setUpContract();
        alice = setUpUser(111, 1);
        bob = setUpUser(222, 2);

        vm.label(address(this), "BuyoutTest");
        vm.label(alice.addr, "Alice");
        vm.label(bob.addr, "Bob");
    }

    /// ========================
    /// ===== START BUYOUT =====
    /// ========================
    function testStart() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        assertEq(getFractionBalance(bob.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(bob.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 0 ether);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(bob.addr), 99 ether);
        assertEq(getETHBalance(buyout), 1 ether);
    }

    function testStartNoFractions() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, 0, true);

        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(bob.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 0 ether);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(bob.addr), 99 ether);
        assertEq(getETHBalance(buyout), 1 ether);
    }

    function testStartRevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.start{value: 1 ether}(address(baseVault), amount);
    }

    function testStartRevertStateLIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        alice.buyoutModule.start{value: 1 ether}(vault, amount);

        revertBuyoutState(State.INACTIVE, State.LIVE);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
    }

    function testStartRevertZeroDeposit() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        vm.expectRevert(abi.encodeWithSelector(IBuyout.ZeroDeposit.selector));
        bob.buyoutModule.start(vault, amount);
    }

    function testStartRevertNotApproved() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, false);

        uint256 amount = IERC1155(token).balanceOf(alice.addr, tokenId);
        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        alice.buyoutModule.start{value: 1 ether}(vault, amount);
    }

    function testStartRevertTotalSupply() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, 0, true);

        uint256 amount = IERC1155(token).balanceOf(alice.addr, tokenId);
        vm.expectRevert(stdError.divisionError);
        alice.buyoutModule.start{value: 1 ether}(vault, amount);
    }

    /// ==========================
    /// ===== SELL FRACTIONS =====
    /// ==========================
    function testSellFractions() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 1 ether);

        alice.buyoutModule.sellFractions(vault, 1000);

        assertEq(getFractionBalance(alice.addr), 4000);
        assertEq(getFractionBalance(buyout), 6000);
        assertEq(getETHBalance(alice.addr), 100.2 ether);
        assertEq(getETHBalance(buyout), 0.8 ether);
    }

    function testSellFractionsSelfPermit() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 1 ether);

        alice.ferc1155 = new FERC1155BS(address(0), 111, token);
        alice.ferc1155.setApprovalForAll(buyout, false);
        (uint8 v, bytes32 r, bytes32 s) = signPermitAll(
            alice,
            buyout,
            true,
            FERC1155(token).nonces(alice.addr),
            block.timestamp + 1
        );

        alice.buyoutModule.selfPermitAll(
            token,
            true,
            block.timestamp + 1,
            v,
            r,
            s
        );

        alice.buyoutModule.sellFractions(vault, 1000);

        assertEq(getFractionBalance(alice.addr), 4000);
        assertEq(getFractionBalance(buyout), 6000);
        assertEq(getETHBalance(alice.addr), 100.2 ether);
        assertEq(getETHBalance(buyout), 0.8 ether);
    }

    function testSellFractionsNoDepositAmount() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        alice.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), 0);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), 99 ether);
        assertEq(getETHBalance(buyout), 1 ether);

        alice.buyoutModule.sellFractions(vault, 0);

        assertEq(getFractionBalance(alice.addr), 0);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), 99 ether);
        assertEq(getETHBalance(buyout), 1 ether);
    }

    function testSellFractionsRevertTimeExpired() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        vm.warp(proposalPeriod + 1);

        uint256 expected = block.timestamp - 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.TimeExpired.selector,
                block.timestamp,
                expected
            )
        );
        alice.buyoutModule.sellFractions(vault, 1000);
    }

    function testSellFractionsRevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        alice.buyoutModule.sellFractions(address(baseVault), 1000);
    }

    function testSellFractionsRevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        revertBuyoutState(State.LIVE, State.INACTIVE);
        alice.buyoutModule.sellFractions(vault, 1000);
    }

    function testSellFractionsRevertNotApproved() public {
        deployBaseVault(alice, TOTAL_SUPPLY);
        (token, tokenId) = registry.vaultToToken(vault);
        bob.ferc1155 = new FERC1155BS(address(0), 222, address(token));
        setApproval(bob, vault, true);
        setApproval(bob, address(buyoutModule), true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        alice.buyoutModule.sellFractions(vault, 1000);
    }

    /// =========================
    /// ===== BUY FRACTIONS =====
    /// =========================
    function testBuyFractionsSingle() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 1 ether);

        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);

        assertEq(getFractionBalance(alice.addr), 6000);
        assertEq(getFractionBalance(buyout), 4000);
        assertEq(getETHBalance(alice.addr), 99.8 ether);
        assertEq(getETHBalance(buyout), 1.2 ether);
    }

    function testBuyFractionsOutbid() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(bob.addr), 99 ether);
        assertEq(getETHBalance(buyout), 1 ether);

        alice.buyoutModule.buyFractions{value: 1 ether}(vault, HALF_SUPPLY);

        assertEq(getFractionBalance(alice.addr), TOTAL_SUPPLY);
        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(alice.addr), 99 ether);
        assertEq(getETHBalance(bob.addr), 101 ether);
        assertEq(getETHBalance(buyout), 0 ether);

        alice.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), 98 ether);
        assertEq(getETHBalance(buyout), 1 ether);
    }

    function testBuyFractionsNoDepositAmount() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 1 ether);

        alice.buyoutModule.buyFractions{value: 0 ether}(vault, 0);

        assertEq(getFractionBalance(alice.addr), HALF_SUPPLY);
        assertEq(getFractionBalance(buyout), HALF_SUPPLY);
        assertEq(getETHBalance(alice.addr), INITIAL_BALANCE);
        assertEq(getETHBalance(buyout), 1 ether);
    }

    function testBuyFractionsNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        alice.buyoutModule.buyFractions{value: 0.2 ether}(
            address(baseVault),
            1000
        );
    }

    function testBuyFractionsRevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        revertBuyoutState(State.LIVE, State.INACTIVE);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
    }

    function testBuyFractionsRevertTimeExpired() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        vm.warp(rejectionPeriod + 1);
        uint256 expected = block.timestamp - 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.TimeExpired.selector,
                block.timestamp,
                expected
            )
        );

        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
    }

    function testBuyFractionsRevertInvalidPayment() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        vm.expectRevert(
            abi.encodeWithSelector(IBuyout.InvalidPayment.selector)
        );

        alice.buyoutModule.buyFractions{value: 0.19 ether}(vault, 1000);
    }

    /// ======================
    /// ===== END BUYOUT =====
    /// ======================
    function testEndSuccesfull() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);

        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), 6000);

        bob.buyoutModule.end(vault, burnProof);

        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), 0);
    }

    function testEndUnsuccesfull() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod + 1);

        assertEq(getFractionBalance(bob.addr), 0);
        assertEq(getFractionBalance(buyout), 4000);
        assertEq(getETHBalance(bob.addr), 99 ether);
        assertEq(getETHBalance(buyout), 1.2 ether);

        bob.buyoutModule.end(vault, burnProof);

        assertEq(getFractionBalance(bob.addr), 4000);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(bob.addr), 100.2 ether);
        assertEq(getETHBalance(buyout), 0 ether);
    }

    function testEndRevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.sellFractions(vault, 1000);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.end(address(baseVault), burnProof);
    }

    function testEndRevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        revertBuyoutState(State.LIVE, State.INACTIVE);
        bob.buyoutModule.end(vault, burnProof);
    }

    function testEndRevertTimeNotElapsed() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.TimeNotElapsed.selector,
                block.timestamp,
                block.timestamp
            )
        );
        bob.buyoutModule.end(vault, burnProof);
    }

    /// ====================
    /// ===== CASH OUT =====
    /// ====================
    function testCash() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpBuyoutCash(alice, bob);

        assertEq(getFractionBalance(alice.addr), 4000);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(alice.addr), 100.2 ether);
        assertEq(getETHBalance(buyout), 0.8 ether);

        alice.buyoutModule.cash(vault, burnProof);

        assertEq(getFractionBalance(alice.addr), 0);
        assertEq(getFractionBalance(buyout), 0);
        assertEq(getETHBalance(alice.addr), 101 ether);
        assertEq(getETHBalance(buyout), 0 ether);
    }

    function testCashRevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpBuyoutCash(alice, bob);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.cash(address(baseVault), burnProof);
    }

    function testCashRevertStateLIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod);

        revertBuyoutState(State.SUCCESS, State.LIVE);
        bob.buyoutModule.cash(vault, burnProof);
    }

    function testCashRevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        bob.buyoutModule.end(vault, burnProof);

        revertBuyoutState(State.SUCCESS, State.INACTIVE);
        bob.buyoutModule.cash(vault, burnProof);
    }

    function testCashRevertNoFractions() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        bob.buyoutModule.end(vault, burnProof);

        vm.expectRevert(abi.encodeWithSelector(IBuyout.NoFractions.selector));
        bob.buyoutModule.cash(vault, burnProof);
    }

    // ======================
    // ===== REDEEM NFT =====
    // ======================
    function testRedeem() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, TOTAL_SUPPLY, true);

        assertEq(getFractionBalance(bob.addr), TOTAL_SUPPLY);
        bob.buyoutModule.redeem(vault, burnProof);
        assertEq(getFractionBalance(bob.addr), 0);
    }

    function testRedeemRevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.redeem(address(baseVault), burnProof);
    }

    function testRedeemRevertStateLIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);

        revertBuyoutState(State.INACTIVE, State.LIVE);
        alice.buyoutModule.redeem(vault, burnProof);
    }

    function testRedeemRevertNotTotalSupply() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        vm.expectRevert(stdError.arithmeticError);
        bob.buyoutModule.redeem(vault, burnProof);
    }

    /// ===========================
    /// ===== WITHDRAW ERC721 =====
    /// ===========================
    function testWithdrawERC721() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC721(alice, bob);

        bytes memory withdrawERC721 = initializeWithdrawalERC721(
            vault,
            bob.addr,
            1
        );
        bytes memory withdraw2ERC721 = initializeWithdrawalERC721(
            vault,
            bob.addr,
            2
        );
        bytes[] memory data = new bytes[](2);
        data[0] = withdrawERC721;
        data[1] = withdraw2ERC721;

        assertEq(IERC721(erc721).balanceOf(bob.addr), 0);
        bob.buyoutModule.multicall(data);
        assertEq(IERC721(erc721).balanceOf(bob.addr), 2);
    }

    function testWithdrawERC721Redeem() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, TOTAL_SUPPLY, true);
        bob.erc721.safeTransferFrom(bob.addr, vault, 2);
        bob.buyoutModule.redeem(vault, burnProof);

        bytes memory withdrawERC721 = initializeWithdrawalERC721(
            vault,
            bob.addr,
            1
        );
        bytes memory withdraw2ERC721 = initializeWithdrawalERC721(
            vault,
            bob.addr,
            2
        );
        bytes[] memory data = new bytes[](2);
        data[0] = withdrawERC721;
        data[1] = withdraw2ERC721;

        bob.buyoutModule.multicall(data);
        assertEq(IERC721(erc721).balanceOf(bob.addr), 2);
    }

    function testWithdrawERC721RevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC721(alice, bob);

        bytes memory withdrawERC721 = initializeWithdrawalERC721(
            address(baseVault),
            bob.addr,
            1
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC721;

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.multicall(data);
    }

    function testWithdrawERC721RevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        bob.buyoutModule.end(vault, burnProof);

        revertBuyoutState(State.SUCCESS, State.INACTIVE);
        bob.buyoutModule.withdrawERC721(
            vault,
            address(erc721),
            bob.addr,
            1,
            erc721TransferProof
        );
    }

    function testWithdrawERC721RevertNotAllowed() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC721(alice, bob);

        bytes memory withdrawERC721 = initializeWithdrawalERC721(
            vault,
            alice.addr,
            1
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC721;

        vm.expectRevert(abi.encodeWithSelector(IBuyout.NotWinner.selector));
        alice.buyoutModule.multicall(data);
    }

    /// ============================
    /// ===== WITHDRAW ERC1155 =====
    /// ============================
    function testWithdrawERC1155() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC1155(alice, bob);

        bytes memory withdrawERC1155 = initializeWithdrawalERC1155(
            vault,
            bob.addr,
            1,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC1155;

        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 1), 0);
        bob.buyoutModule.multicall(data);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 1), 10);
    }

    function testWithdrawERC1155Redeem() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, TOTAL_SUPPLY, true);
        MockERC1155(erc1155).mint(vault, 1, 10, "");
        bob.buyoutModule.redeem(vault, burnProof);

        bytes memory withdrawERC1155 = initializeWithdrawalERC1155(
            vault,
            bob.addr,
            1,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC1155;

        bob.buyoutModule.multicall(data);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 1), 10);
    }

    function testWithdrawERC1155RevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC1155(alice, bob);

        bytes memory withdrawERC1155 = initializeWithdrawalERC1155(
            address(baseVault),
            bob.addr,
            1,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC1155;

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.multicall(data);
    }

    function testWithdrawERC1155RevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        bob.buyoutModule.end(vault, burnProof);

        revertBuyoutState(State.SUCCESS, State.INACTIVE);
        bob.buyoutModule.withdrawERC1155(
            vault,
            address(erc1155),
            bob.addr,
            1,
            10,
            erc1155TransferProof
        );
    }

    function testWithdrawERC1155RevertNotAllowed() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC1155(alice, bob);

        bytes memory withdrawERC1155 = initializeWithdrawalERC1155(
            vault,
            alice.addr,
            1,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC1155;

        vm.expectRevert(abi.encodeWithSelector(IBuyout.NotWinner.selector));
        alice.buyoutModule.multicall(data);
    }

    /// ==================================
    /// ===== BATCH WITHDRAW ERC1155 =====
    /// ==================================
    function testBatchWithdrawERC1155() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpBatchWithdrawERC1155(alice, bob);

        bytes memory batchWithdrawERC1155 = initializeBatchWithdrawalERC1155(
            vault,
            bob.addr,
            3
        );
        bytes[] memory data = new bytes[](1);
        data[0] = batchWithdrawERC1155;

        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 1), 0);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 2), 0);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 3), 0);

        bob.buyoutModule.multicall(data);

        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 1), 10);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 2), 10);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 3), 10);
    }

    function testBatchWithdrawERC1155Redeem() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, TOTAL_SUPPLY, true);
        mintERC1155(vault, 3);
        bob.buyoutModule.redeem(vault, burnProof);

        bytes memory batchWithdrawERC1155 = initializeBatchWithdrawalERC1155(
            vault,
            bob.addr,
            3
        );
        bytes[] memory data = new bytes[](1);
        data[0] = batchWithdrawERC1155;

        bob.buyoutModule.multicall(data);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 1), 10);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 2), 10);
        assertEq(IERC1155(erc1155).balanceOf(bob.addr, 3), 10);
    }

    function testBatchWithdrawERC1155RevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpBatchWithdrawERC1155(alice, bob);

        bytes memory batchWithdrawERC1155 = initializeBatchWithdrawalERC1155(
            address(baseVault),
            bob.addr,
            3
        );
        bytes[] memory data = new bytes[](1);
        data[0] = batchWithdrawERC1155;

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.multicall(data);
    }

    function testBatchWithdrawERC1155RevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        bob.buyoutModule.end(vault, burnProof);

        uint256[] memory ids = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        for (uint256 i; i < 3; i++) {
            ids[i] = i + 1;
            amounts[i] = 10;
        }

        revertBuyoutState(State.SUCCESS, State.INACTIVE);
        bob.buyoutModule.batchWithdrawERC1155(
            vault,
            address(erc1155),
            bob.addr,
            ids,
            amounts,
            erc1155BatchTransferProof
        );
    }

    function testBatchWithdrawERC1155RevertNotAllowed() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpBatchWithdrawERC1155(alice, bob);

        bytes memory batchWithdrawERC1155 = initializeBatchWithdrawalERC1155(
            vault,
            alice.addr,
            3
        );
        bytes[] memory data = new bytes[](1);
        data[0] = batchWithdrawERC1155;

        vm.expectRevert(abi.encodeWithSelector(IBuyout.NotWinner.selector));
        alice.buyoutModule.multicall(data);
    }

    /// ============================
    /// ===== WITHDRAW ERC20 =======
    /// ============================
    function testWithdrawERC20() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC20(alice, bob);

        bytes memory withdrawERC20 = initializeWithdrawalERC20(
            vault,
            bob.addr,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC20;
        IERC20(erc20).balanceOf(vault);
        assertEq(IERC20(erc20).balanceOf(bob.addr), 0);
        bob.buyoutModule.multicall(data);
        assertEq(IERC20(erc20).balanceOf(bob.addr), 10);
    }

    function testWithdrawERC20Redeem() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, TOTAL_SUPPLY, true);
        MockERC20(erc20).mint(vault, 10);
        bob.buyoutModule.redeem(vault, burnProof);

        bytes memory withdrawERC20 = initializeWithdrawalERC20(
            vault,
            bob.addr,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC20;
        IERC20(erc20).balanceOf(vault);
        bob.buyoutModule.multicall(data);
        assertEq(IERC20(erc20).balanceOf(bob.addr), 10);
    }

    function testWithdrawERC20RevertNotAVault() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC1155(alice, bob);

        bytes memory withdrawERC20 = initializeWithdrawalERC20(
            address(baseVault),
            bob.addr,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC20;

        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.NotVault.selector,
                address(baseVault)
            )
        );
        bob.buyoutModule.multicall(data);
    }

    function testWithdrawERC20RevertStateINACTIVE() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);

        uint256 amount = IERC1155(token).balanceOf(bob.addr, tokenId);
        bob.buyoutModule.start{value: 1 ether}(vault, amount);
        alice.buyoutModule.buyFractions{value: 0.2 ether}(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        bob.buyoutModule.end(vault, burnProof);

        revertBuyoutState(State.SUCCESS, State.INACTIVE);
        bob.buyoutModule.withdrawERC20(
            vault,
            address(erc20),
            bob.addr,
            10,
            erc20TransferProof
        );
    }

    function testWithdrawERC20RevertNotAllowed() public {
        initializeBuyout(alice, bob, TOTAL_SUPPLY, HALF_SUPPLY, true);
        setUpWithdrawERC20(alice, bob);

        bytes memory withdrawERC20 = initializeWithdrawalERC20(
            vault,
            alice.addr,
            10
        );
        bytes[] memory data = new bytes[](1);
        data[0] = withdrawERC20;

        vm.expectRevert(abi.encodeWithSelector(IBuyout.NotWinner.selector));
        alice.buyoutModule.multicall(data);
    }
}
