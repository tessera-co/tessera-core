// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "./TestUtil.sol";

contract BaseVaultTest is TestUtil {
    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        setUpContract();
        alice = setUpUser(111, 1);
        setUpCreateFor(alice);
        setUpMulticall(alice);

        vm.label(address(this), "BaseVaultTest");
        vm.label(alice.addr, "Alice");
    }

    /// ========================
    /// ===== DEPLOY VAULT =====
    /// ========================
    function testDeploy() public {
        vault = alice.baseVault.deployVault(
            TOTAL_SUPPLY,
            modules,
            nftReceiverPlugins,
            nftReceiverSelectors,
            mintProof
        );
        (token, tokenId) = registry.vaultToToken(vault);

        assertEq(getFractionBalance(alice.addr), TOTAL_SUPPLY);
    }

    /// =====================
    /// ===== MULTICALL =====
    /// =====================
    function xtestMulticallDeploy() public {
        factory = registry.factory();
        vault = IVaultFactory(factory).getNextAddress(alice.addr, merkleRoot);
        alice.erc721.safeTransferFrom(alice.addr, vault, 1);
        bytes memory deployVault = initializeDeploy();
        bytes memory depositERC721 = initializeDepositERC721(2);
        bytes[] memory data = new bytes[](2);
        data[0] = deployVault;
        data[1] = depositERC721;

        assertEq(IERC721(erc721).balanceOf(alice.addr), 3);
        assertEq(IERC721(erc721).balanceOf(vault), 0);

        alice.baseVault.multicall(data);

        assertEq(IERC721(erc721).balanceOf(alice.addr), 0);
        assertEq(IERC721(erc721).balanceOf(vault), 3);
    }

    function testMulticallDeposit() public {
        deployBaseVault(alice, TOTAL_SUPPLY);
        bytes memory depositERC721 = initializeDepositERC721(2);
        bytes memory depositERC1155 = initializeDepositERC1155(2);
        bytes memory depositERC20 = initializeDepositERC20(10);
        bytes[] memory data = new bytes[](3);
        data[0] = depositERC721;
        data[1] = depositERC1155;
        data[2] = depositERC20;

        assertEq(IERC721(erc721).balanceOf(alice.addr), 2);
        assertEq(IERC1155(erc1155).balanceOf(alice.addr, 1), 10);
        assertEq(IERC1155(erc1155).balanceOf(alice.addr, 2), 10);
        assertEq(IERC20(erc20).balanceOf(alice.addr), 10);

        alice.baseVault.multicall(data);

        assertEq(IERC721(erc721).balanceOf(vault), 3);
        assertEq(IERC1155(erc1155).balanceOf(vault, 1), 10);
        assertEq(IERC1155(erc1155).balanceOf(vault, 2), 10);
        assertEq(IERC20(erc20).balanceOf(vault), 10);
    }

    function xtestMulticallDeployDeposits() public {
        factory = registry.factory();
        vault = IVaultFactory(factory).getNextAddress(alice.addr, merkleRoot);
        alice.erc721.safeTransferFrom(alice.addr, vault, 1);
        bytes memory deployVault = initializeDeploy();
        bytes memory depositERC721 = initializeDepositERC721(2);
        bytes memory depositERC1155 = initializeDepositERC1155(2);
        bytes memory depositERC20 = initializeDepositERC20(10);
        bytes[] memory data = new bytes[](4);
        data[0] = deployVault;
        data[1] = depositERC721;
        data[2] = depositERC1155;
        data[3] = depositERC20;

        assertEq(IERC721(erc721).balanceOf(alice.addr), 3);
        assertEq(IERC1155(erc1155).balanceOf(alice.addr, 1), 10);
        assertEq(IERC1155(erc1155).balanceOf(alice.addr, 2), 10);
        assertEq(IERC20(erc20).balanceOf(alice.addr), 10);

        alice.baseVault.multicall(data);

        assertEq(IERC721(erc721).balanceOf(vault), 3);
        assertEq(IERC1155(erc1155).balanceOf(vault, 1), 10);
        assertEq(IERC1155(erc1155).balanceOf(vault, 2), 10);
        assertEq(IERC20(erc20).balanceOf(vault), 10);
    }
}
