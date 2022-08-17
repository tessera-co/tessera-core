// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {Blacksmith} from "./blacksmith/Blacksmith.sol";
import {BaseVault, BaseVaultBS} from "./blacksmith/BaseVault.bs.sol";
import {Buyout, BuyoutBS} from "./blacksmith/Buyout.bs.sol";
import {FERC1155, FERC1155BS} from "./blacksmith/FERC1155.bs.sol";
import {Metadata, MetadataBS} from "./blacksmith/Metadata.bs.sol";
import {Minter} from "../src/modules/Minter.sol";
import {MockModule} from "../src/mocks/MockModule.sol";
import {MockERC20, MockERC20BS} from "./blacksmith/MockERC20.bs.sol";
import {MockERC721, MockERC721BS} from "./blacksmith/MockERC721.bs.sol";
import {MockERC1155, MockERC1155BS} from "./blacksmith/MockERC1155.bs.sol";
import {NFTReceiver} from "../src/utils/NFTReceiver.sol";
import {Supply, SupplyBS} from "./blacksmith/Supply.bs.sol";
import {Transfer, TransferBS} from "./blacksmith/Transfer.bs.sol";
import {TransferReference} from "../src/references/TransferReference.sol";
import {Vault, VaultBS} from "./blacksmith/Vault.bs.sol";
import {VaultFactory, VaultFactoryBS} from "./blacksmith/VaultFactory.bs.sol";
import {VaultRegistry, VaultRegistryBS} from "./blacksmith/VaultRegistry.bs.sol";
import {WETH} from "@rari-capital/solmate/src/tokens/WETH.sol";

import {IBuyout, State} from "../src/interfaces/IBuyout.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";
import {IERC1155} from "../src/interfaces/IERC1155.sol";
import {IFERC1155} from "../src/interfaces/IFERC1155.sol";
import {IModule} from "../src/interfaces/IModule.sol";
import {IVault} from "../src/interfaces/IVault.sol";
import {IVaultFactory} from "../src/interfaces/IVaultFactory.sol";
import {IVaultRegistry} from "../src/interfaces/IVaultRegistry.sol";

import "../src/constants/Permit.sol";

contract TestUtil is Test {
    BaseVault baseVault;
    Buyout buyoutModule;
    Metadata metadata;
    Minter minter;
    MockModule mockModule;
    NFTReceiver receiver;
    Supply supplyTarget;
    Transfer transferTarget;
    Vault vaultProxy;
    VaultRegistry registry;
    WETH weth;

    FERC1155BS fERC1155;

    struct User {
        address addr;
        uint256 pkey;
        Blacksmith base;
        BaseVaultBS baseVault;
        BuyoutBS buyoutModule;
        MockERC721BS erc721;
        MockERC1155BS erc1155;
        MockERC20BS erc20;
        TransferBS transfer;
        VaultRegistryBS registry;
        FERC1155BS ferc1155;
        VaultBS vaultProxy;
    }

    User alice;
    User bob;
    User eve;
    address buyout;
    address erc20;
    address erc721;
    address erc1155;
    address factory;
    address token;
    address vault;
    bool approved;
    uint256 deadline;
    uint256 nonce;
    uint256 proposalPeriod;
    uint256 rejectionPeriod;
    uint256 tokenId;

    address[] modules = new address[](2);

    bytes32 merkleRoot;
    bytes32[] merkleTree;
    bytes32[] hashes = new bytes32[](6);
    bytes32[] mintProof = new bytes32[](3);
    bytes32[] burnProof = new bytes32[](3);
    bytes32[] erc20TransferProof = new bytes32[](3);
    bytes32[] erc721TransferProof = new bytes32[](3);
    bytes32[] erc1155TransferProof = new bytes32[](3);
    bytes32[] erc1155BatchTransferProof = new bytes32[](3);

    bytes4[] nftReceiverSelectors = new bytes4[](0);
    address[] nftReceiverPlugins = new address[](0);

    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant TOTAL_SUPPLY = 10000;
    uint256 constant HALF_SUPPLY = TOTAL_SUPPLY / 2;
    address constant WETH_ADDRESS =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    /// =================
    /// ===== USERS =====
    /// =================
    function createUser(address _addr, uint256 _privateKey)
        public
        returns (User memory)
    {
        Blacksmith base = new Blacksmith(_addr, _privateKey);
        BaseVaultBS _minter = new BaseVaultBS(
            _addr,
            _privateKey,
            address(baseVault)
        );
        BuyoutBS _buyout = new BuyoutBS(
            _addr,
            _privateKey,
            address(buyoutModule)
        );
        MockERC721BS _erc721 = new MockERC721BS(
            _addr,
            _privateKey,
            address(erc721)
        );
        MockERC1155BS _erc1155 = new MockERC1155BS(
            _addr,
            _privateKey,
            address(erc1155)
        );
        MockERC20BS _erc20 = new MockERC20BS(
            _addr,
            _privateKey,
            address(erc20)
        );
        TransferBS _transfer = new TransferBS(
            _addr,
            _privateKey,
            address(transferTarget)
        );
        VaultRegistryBS _registry = new VaultRegistryBS(
            _addr,
            _privateKey,
            address(registry)
        );
        FERC1155BS _ferc1155 = new FERC1155BS(_addr, _privateKey, address(0));
        VaultBS _proxy = new VaultBS(_addr, _privateKey, address(0));
        base.deal(INITIAL_BALANCE);
        return
            User(
                base.addr(),
                base.pkey(),
                base,
                _minter,
                _buyout,
                _erc721,
                _erc1155,
                _erc20,
                _transfer,
                _registry,
                _ferc1155,
                _proxy
            );
    }

    /// ==================
    /// ===== SETUPS =====
    /// ==================
    function setUpContract() public {
        registry = new VaultRegistry();
        supplyTarget = new Supply(address(registry));
        minter = new Minter(address(supplyTarget));
        transferTarget = new Transfer();
        receiver = new NFTReceiver();
        buyoutModule = new Buyout(
            address(registry),
            address(supplyTarget),
            address(transferTarget)
        );
        baseVault = new BaseVault(address(registry), address(supplyTarget));
        erc20 = address(new MockERC20());
        erc721 = address(new MockERC721());
        erc1155 = address(new MockERC1155());

        vm.label(address(registry), "VaultRegistry");
        vm.label(address(supplyTarget), "SupplyTarget");
        vm.label(address(transferTarget), "TransferTarget");
        vm.label(address(baseVault), "BaseVault");
        vm.label(address(buyoutModule), "BuyoutModule");
        vm.label(address(erc20), "ERC20");
        vm.label(address(erc721), "ERC721");
        vm.label(address(erc1155), "ERC1155");

        setUpWETH();
        setUpProof();
    }

    function setUpWETH() public {
        WETH _weth = new WETH();
        bytes memory code = address(_weth).code;
        vm.etch(WETH_ADDRESS, code);
        weth = WETH(payable(WETH_ADDRESS));

        vm.label(WETH_ADDRESS, "WETH");
    }

    function setUpProof() public {
        modules[0] = address(baseVault);
        modules[1] = address(buyoutModule);

        hashes[0] = baseVault.getLeafNodes()[0];
        hashes[1] = buyoutModule.getLeafNodes()[0];
        hashes[2] = buyoutModule.getLeafNodes()[1];
        hashes[3] = buyoutModule.getLeafNodes()[2];
        hashes[4] = buyoutModule.getLeafNodes()[3];
        hashes[5] = buyoutModule.getLeafNodes()[4];

        merkleTree = baseVault.generateMerkleTree(modules);
        merkleRoot = baseVault.getRoot(merkleTree);
        mintProof = baseVault.getProof(hashes, 0);
        burnProof = baseVault.getProof(hashes, 1);
        erc20TransferProof = baseVault.getProof(hashes, 2);
        erc721TransferProof = baseVault.getProof(hashes, 3);
        erc1155TransferProof = baseVault.getProof(hashes, 4);
        erc1155BatchTransferProof = baseVault.getProof(hashes, 5);
    }

    function setUpUser(uint256 _privateKey, uint256 _tokenId)
        public
        returns (User memory user)
    {
        user = createUser(address(0), _privateKey);
        MockERC721(erc721).mint(user.addr, _tokenId);
    }

    /// =======================
    /// ===== VAULT PROXY =====
    /// =======================
    function setUpExecute(User memory _user)
        public
        returns (bytes memory data)
    {
        (nftReceiverSelectors, nftReceiverPlugins) = initializeNFTReceiver();
        IVault(vault).setPlugins(nftReceiverPlugins, nftReceiverSelectors);
        _user.erc721.safeTransferFrom(_user.addr, vault, 1);
        data = abi.encodeCall(
            transferTarget.ERC721TransferFrom,
            (address(erc721), vault, _user.addr, 1)
        );
    }

    /// ==========================
    /// ===== VAULT REGISTRY =====
    /// ==========================
    function setUpCreateFor(User memory _user) public {
        (nftReceiverSelectors, nftReceiverPlugins) = initializeNFTReceiver();
        vault = registry.createFor(
            merkleRoot,
            _user.addr,
            nftReceiverPlugins,
            nftReceiverSelectors
        );

        vm.label(vault, "VaultProxy");
    }

    /// ====================
    /// ===== FERC1155 =====
    /// ====================
    function setUpPermit(
        User memory _user,
        bool _approved,
        uint256 _deadline
    ) public {
        approved = _approved;
        deadline = _deadline;
        _user.erc721.safeTransferFrom(_user.addr, vault, 1);
        (token, tokenId) = registry.vaultToToken(vault);
        nonce = FERC1155(token).nonces(_user.addr);
        setUpFERC1155(_user, token);

        vm.label(vault, "VaultProxy");
    }

    function setUpMetadata(User memory _user) public {
        (nftReceiverSelectors, nftReceiverPlugins) = initializeNFTReceiver();
        (vault, token) = registry.createCollectionFor(
            merkleRoot,
            _user.addr,
            nftReceiverPlugins,
            nftReceiverSelectors
        );
        (, tokenId) = registry.vaultToToken(address(vault));
        setUpFERC1155(_user, token);
        metadata = new Metadata(fERC1155.proxyContract());

        vm.label(address(metadata), "Metadata");
    }

    function setUpFERC1155(User memory _user, address _ferc1155) public {
        fERC1155 = new FERC1155BS(address(0), _user.pkey, _ferc1155);

        vm.label(token, "Token");
    }

    /// ======================
    /// ===== BASE VAULT =====
    /// ======================
    function deployBaseVault(User memory _user, uint256 _fractions) public {
        vault = _user.baseVault.deployVault(
            _fractions,
            modules,
            nftReceiverPlugins,
            nftReceiverSelectors,
            mintProof
        );
        _user.erc721.safeTransferFrom(_user.addr, vault, 1);
        vm.label(vault, "VaultProxy");
    }

    function setUpMulticall(User memory _user) public {
        MockERC20(erc20).mint(_user.addr, 10);
        MockERC721(erc721).mint(_user.addr, 2);
        MockERC721(erc721).mint(_user.addr, 3);
        mintERC1155(_user.addr, 2);

        _user.erc20.approve(address(baseVault), 10);
        _user.erc721.setApprovalForAll(address(baseVault), true);
        _user.erc1155.setApprovalForAll(address(baseVault), true);
    }

    /// ==================
    /// ===== BUYOUT =====
    /// ==================
    function setUpBuyout(
        User memory _user1,
        User memory _user2,
        uint256 _fractions
    ) public {
        deployBaseVault(_user1, _fractions);
        (token, tokenId) = registry.vaultToToken(vault);
        _user1.ferc1155 = new FERC1155BS(address(0), 111, token);
        _user2.ferc1155 = new FERC1155BS(address(0), 222, token);

        buyout = address(buyoutModule);
        proposalPeriod = buyoutModule.PROPOSAL_PERIOD();
        rejectionPeriod = buyoutModule.REJECTION_PERIOD();

        vm.label(vault, "VaultProxy");
        vm.label(token, "Token");
    }

    function setUpBuyoutCash(User memory _user1, User memory _user2) public {
        uint256 amount = IERC1155(token).balanceOf(_user2.addr, tokenId);
        _user2.buyoutModule.start{value: 1 ether}(vault, amount);
        _user1.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        _user2.buyoutModule.end(vault, burnProof);
    }

    function setUpWithdrawERC721(User memory _user1, User memory _user2)
        public
    {
        _user2.erc721.safeTransferFrom(_user2.addr, vault, 2);
        uint256 amount = IERC1155(token).balanceOf(_user2.addr, tokenId);
        _user2.buyoutModule.start{value: 1 ether}(vault, amount);
        _user1.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        _user2.buyoutModule.end(vault, burnProof);
        _user1.buyoutModule.cash(vault, burnProof);
    }

    function setUpWithdrawERC1155(User memory _user1, User memory _user2)
        public
    {
        mintERC1155(vault, 1);
        uint256 amount = IERC1155(token).balanceOf(_user2.addr, tokenId);
        _user2.buyoutModule.start{value: 1 ether}(vault, amount);
        _user1.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        _user2.buyoutModule.end(vault, burnProof);
        _user1.buyoutModule.cash(vault, burnProof);
    }

    function mintERC1155(address _to, uint256 _count) public {
        for (uint256 i = 1; i <= _count; i++) {
            MockERC1155(erc1155).mint(_to, i, 10, "");
        }
    }

    function setUpBatchWithdrawERC1155(User memory _user1, User memory _user2)
        public
    {
        mintERC1155(vault, 3);
        uint256 amount = IERC1155(token).balanceOf(_user2.addr, tokenId);
        _user2.buyoutModule.start{value: 1 ether}(vault, amount);
        _user1.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        _user2.buyoutModule.end(vault, burnProof);
        _user1.buyoutModule.cash(vault, burnProof);
    }

    function setUpWithdrawERC20(User memory _user1, User memory _user2) public {
        MockERC20(erc20).mint(vault, 10);
        uint256 amount = IERC1155(token).balanceOf(_user2.addr, tokenId);
        _user2.buyoutModule.start{value: 1 ether}(vault, amount);
        _user1.buyoutModule.sellFractions(vault, 1000);
        vm.warp(rejectionPeriod + 1);
        _user2.buyoutModule.end(vault, burnProof);
        _user1.buyoutModule.cash(vault, burnProof);
    }

    /// ===========================
    /// ===== INITIALIZATIONS =====
    /// ===========================
    function initializeDeploy() public view returns (bytes memory deployVault) {
        deployVault = abi.encodeCall(
            baseVault.deployVault,
            (
                TOTAL_SUPPLY,
                modules,
                nftReceiverPlugins,
                nftReceiverSelectors,
                mintProof
            )
        );
    }

    function initializeDepositERC20(uint256 _amount)
        public
        view
        returns (bytes memory depositERC721)
    {
        address[] memory tokens = new address[](1);
        tokens[0] = erc20;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;

        depositERC721 = abi.encodeCall(
            baseVault.batchDepositERC20,
            (vault, tokens, amounts)
        );
    }

    function initializeDepositERC721(uint256 _count)
        public
        view
        returns (bytes memory depositERC721)
    {
        address[] memory nfts = new address[](_count);
        uint256[] memory tokenIds = new uint256[](_count);
        for (uint256 i; i < _count; i++) {
            nfts[i] = erc721;
            tokenIds[i] = i + 2;
        }

        depositERC721 = abi.encodeCall(
            baseVault.batchDepositERC721,
            (vault, nfts, tokenIds)
        );
    }

    function initializeDepositERC1155(uint256 _count)
        public
        view
        returns (bytes memory depositERC1155)
    {
        address[] memory nfts = new address[](_count);
        uint256[] memory tokenIds = new uint256[](_count);
        uint256[] memory amounts = new uint256[](_count);
        bytes[] memory data = new bytes[](_count);
        for (uint256 i; i < _count; i++) {
            nfts[i] = erc1155;
            tokenIds[i] = i + 1;
            amounts[i] = 10;
            data[i] = "";
        }

        depositERC1155 = abi.encodeCall(
            baseVault.batchDepositERC1155,
            (vault, nfts, tokenIds, amounts, data)
        );
    }

    function initializeMismatchPlugin()
        public
        view
        returns (bytes4[] memory, address[] memory)
    {
        address[] memory plugins = new address[](2);
        bytes4[] memory selectors = new bytes4[](3);

        (plugins[0], plugins[1]) = (address(receiver), address(receiver));
        (selectors[0], selectors[1], selectors[2]) = (
            receiver.onERC1155Received.selector,
            receiver.onERC1155BatchReceived.selector,
            receiver.onERC721Received.selector
        );
        return (selectors, plugins);
    }

    function initializeNFTReceiver()
        public
        view
        returns (bytes4[] memory, address[] memory)
    {
        address[] memory plugins = new address[](3);
        bytes4[] memory selectors = new bytes4[](3);

        (plugins[0], plugins[1], plugins[2]) = (
            address(receiver),
            address(receiver),
            address(receiver)
        );
        (selectors[0], selectors[1], selectors[2]) = (
            receiver.onERC1155Received.selector,
            receiver.onERC1155BatchReceived.selector,
            receiver.onERC721Received.selector
        );
        return (selectors, plugins);
    }

    function initializeBuyout(
        User memory _user1,
        User memory _user2,
        uint256 _totalSupply,
        uint256 _amount,
        bool _approval
    ) public {
        setUpBuyout(_user1, _user2, _totalSupply);
        _user1.ferc1155.safeTransferFrom(
            _user1.addr,
            _user2.addr,
            1,
            _amount,
            ""
        );
        setApproval(_user1, vault, _approval);
        setApproval(_user1, buyout, _approval);
        setApproval(_user2, vault, _approval);
        setApproval(_user2, buyout, _approval);
    }

    function initializeWithdrawalERC721(
        address _from,
        address _to,
        uint256 _tokenId
    ) public view returns (bytes memory withdrawERC721) {
        withdrawERC721 = abi.encodeCall(
            buyoutModule.withdrawERC721,
            (_from, erc721, _to, _tokenId, erc721TransferProof)
        );
    }

    function initializeWithdrawalERC1155(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) public view returns (bytes memory withdrawERC1155) {
        withdrawERC1155 = abi.encodeCall(
            buyoutModule.withdrawERC1155,
            (_from, erc1155, _to, _id, _amount, erc1155TransferProof)
        );
    }

    function initializeBatchWithdrawalERC1155(
        address _from,
        address _to,
        uint256 _count
    ) public view returns (bytes memory batchWithdrawERC1155) {
        uint256[] memory ids = new uint256[](_count);
        uint256[] memory amounts = new uint256[](_count);
        for (uint256 i; i < _count; i++) {
            ids[i] = i + 1;
            amounts[i] = 10;
        }

        batchWithdrawERC1155 = abi.encodeCall(
            buyoutModule.batchWithdrawERC1155,
            (
                _from,
                address(erc1155),
                _to,
                ids,
                amounts,
                erc1155BatchTransferProof
            )
        );
    }

    function initializeWithdrawalERC20(
        address _from,
        address _to,
        uint256 _amount
    ) public view returns (bytes memory withdrawERC20) {
        withdrawERC20 = abi.encodeCall(
            buyoutModule.withdrawERC20,
            (_from, erc20, _to, _amount, erc20TransferProof)
        );
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================
    function setApproval(
        User memory _user,
        address _to,
        bool _approval
    ) public {
        _user.ferc1155.setApprovalForAll(_to, _approval);
    }

    function getFractionBalance(address _account)
        public
        view
        returns (uint256)
    {
        return IERC1155(token).balanceOf(_account, tokenId);
    }

    function getETHBalance(address _account) public view returns (uint256) {
        return _account.balance;
    }

    function revertBuyoutState(State _expected, State _actual) public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IBuyout.InvalidState.selector,
                _expected,
                _actual
            )
        );
    }

    /// ======================
    /// ===== SIGNATURES =====
    /// ======================
    function computeDigest(bytes32 _domainSeparator, bytes32 _structHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", _domainSeparator, _structHash)
            );
    }

    function computeDomainSeparator() public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes("FERC1155")),
                    keccak256(bytes("1")),
                    block.chainid,
                    token
                )
            );
    }

    function signPermit(
        User memory _owner,
        address _operator,
        bool _bool,
        uint256 _nonce,
        uint256 _deadline
    )
        public
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                _owner.addr,
                _operator,
                tokenId,
                _bool,
                _nonce++,
                _deadline
            )
        );

        (v, r, s) = _owner.base.sign(
            computeDigest(computeDomainSeparator(), structHash)
        );
    }

    function signPermitAll(
        User memory _owner,
        address _operator,
        bool _bool,
        uint256 _nonce,
        uint256 _deadline
    )
        public
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_ALL_TYPEHASH,
                _owner.addr,
                _operator,
                _bool,
                _nonce++,
                _deadline
            )
        );

        (v, r, s) = _owner.base.sign(
            computeDigest(computeDomainSeparator(), structHash)
        );
    }
}
