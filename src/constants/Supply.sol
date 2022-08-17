// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Memory.sol";

// abi.encodeWithSignature("mint(address,uint256)")
uint256 constant REGISTRY_MINT_SIGNATURE = (
    0x40c10f1900000000000000000000000000000000000000000000000000000000
);
uint256 constant REGISTRY_MINT_SIG_PTR = 0x00;
uint256 constant REGISTRY_MINT_TO_PRT = 0x04;
uint256 constant REGISTRY_MINT_VALUE_PTR = 0x24;
uint256 constant REGISTRY_MINT_LENGTH = 0x44; // 4 + 32 * 2 == 68

// abi.encodeWithSignature("burn(address,uint256)")
uint256 constant REGISTRY_BURN_SIGNATURE = (
    0x9dc29fac00000000000000000000000000000000000000000000000000000000
);
uint256 constant REGISTRY_BURN_SIG_PTR = 0x00;
uint256 constant REGISTRY_BURN_FROM_PTR = 0x04;
uint256 constant REGISTRY_BURN_VALUE_PTR = 0x24;
uint256 constant REGISTRY_BURN_LENGTH = 0x44; // 4 + 32 * 2 == 68

// ERRORS

// abi.encodeWithSignature("MintError(address)")
uint256 constant MINT_ERROR_SIGNATURE = (
    0x9770b48a00000000000000000000000000000000000000000000000000000000
);
uint256 constant MINT_ERROR_SIG_PTR = 0x00;
uint256 constant MINT_ERROR_ACCOUNT_PTR = 0x04;
uint256 constant MINT_ERROR_LENGTH = 0x24; // 4 + 32 == 36

// abi.encodeWithSignature("BurnError(address)")
uint256 constant BURN_ERROR_SIGNATURE = (
    0xb715ffa700000000000000000000000000000000000000000000000000000000
);
uint256 constant BURN_ERROR_SIG_PTR = 0x00;
uint256 constant BURN_ERROR_ACCOUNT_PTR = 0x04;
uint256 constant BURN_ERROR_LENGTH = 0x24; // 4 + 32 == 36
