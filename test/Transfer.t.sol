// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./TestUtil.sol";

contract TransferTest is TestUtil, NFTReceiver {
    TransferReference transferReference;

    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        setUpContract();
        vaultProxy = new Vault();
        transferReference = new TransferReference();
        vault = address(vaultProxy);
        alice = setUpUser(111, 1);
        alice.vaultProxy = new VaultBS(address(0), 111, vault);

        (nftReceiverSelectors, nftReceiverPlugins) = initializeNFTReceiver();

        vm.label(address(this), "VaultTest");
        vm.label(vault, "VaultProxy");
        vm.label(alice.addr, "Alice");
    }

    function testMeasureGasERC20() public {
        MockERC20(erc20).mint(address(this), 10);

        bytes memory data = abi.encodeCall(
            transferTarget.ERC20Transfer,
            (address(erc20), alice.addr, 10)
        );
        (bool success, bytes memory response) = address(transferTarget)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasERC20_Reference() public {
        MockERC20(erc20).mint(address(this), 10);

        bytes memory data = abi.encodeCall(
            transferReference.ERC20Transfer,
            (address(erc20), alice.addr, 10)
        );
        (bool success, bytes memory response) = address(transferReference)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasERC721() public {
        MockERC721(erc721).mint(address(this), 100);

        bytes memory data = abi.encodeCall(
            transferTarget.ERC721TransferFrom,
            (address(erc721), address(this), alice.addr, 100)
        );
        (bool success, bytes memory response) = address(transferTarget)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasERC721Reference() public {
        MockERC721(erc721).mint(address(this), 100);

        bytes memory data = abi.encodeCall(
            transferReference.ERC721TransferFrom,
            (address(erc721), address(this), alice.addr, 100)
        );
        (bool success, bytes memory response) = address(transferReference)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasERC1155() public {
        MockERC1155(erc1155).mint(address(this), 1, 10, "");

        bytes memory data = abi.encodeCall(
            transferTarget.ERC1155TransferFrom,
            (address(erc1155), address(this), alice.addr, 1, 10)
        );
        (bool success, bytes memory response) = address(transferTarget)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasERC1155Reference() public {
        MockERC1155(erc1155).mint(address(this), 1, 10, "");

        bytes memory data = abi.encodeCall(
            transferReference.ERC1155TransferFrom,
            (address(erc1155), address(this), alice.addr, 1, 10)
        );
        (bool success, bytes memory response) = address(transferReference)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasBatchERC1155() public {
        MockERC1155(erc1155).mint(address(this), 1, 10, "");
        MockERC1155(erc1155).mint(address(this), 2, 10, "");
        MockERC1155(erc1155).mint(address(this), 3, 10, "");
        MockERC1155(erc1155).mint(address(this), 4, 10, "");
        MockERC1155(erc1155).mint(address(this), 5, 10, "");

        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);
        for (uint256 i; i < 5; ++i) {
            ids[i] = i + 1;
            amounts[i] = 10;
        }

        bytes memory data = abi.encodeCall(
            transferTarget.ERC1155BatchTransferFrom,
            (address(erc1155), address(this), alice.addr, ids, amounts)
        );
        (bool success, bytes memory response) = address(transferTarget)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    function testMeasureGasBatchERC1155Reference() public {
        MockERC1155(erc1155).mint(address(this), 1, 10, "");
        MockERC1155(erc1155).mint(address(this), 2, 10, "");
        MockERC1155(erc1155).mint(address(this), 3, 10, "");
        MockERC1155(erc1155).mint(address(this), 4, 10, "");
        MockERC1155(erc1155).mint(address(this), 5, 10, "");

        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);
        for (uint256 i; i < 5; ++i) {
            ids[i] = i + 1;
            amounts[i] = 10;
        }

        bytes memory data = abi.encodeCall(
            transferReference.ERC1155BatchTransferFrom,
            (address(erc1155), address(this), alice.addr, ids, amounts)
        );
        (bool success, bytes memory response) = address(transferReference)
            .delegatecall(data);
        if (!success) {
            if (response.length == 0) revert();
            _revertedWithReason(response);
        }
    }

    /// @notice Reverts transaction with reason
    function _revertedWithReason(bytes memory _response) internal pure {
        assembly {
            let returndata_size := mload(_response)
            revert(add(32, _response), returndata_size)
        }
    }
}
