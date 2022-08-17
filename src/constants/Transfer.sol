// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Memory.sol";

// Modified from Seaport:
// https://github.com/ProjectOpenSea/seaport/blob/main/contracts/lib/TokenTransferrerConstants.sol

/*
 * -------------------------- Disambiguation & Other Notes ---------------------
 *    - The term "head" is used as it is in the documentation for ABI encoding,
 *      but only in reference to dynamic types, i.e. it always refers to the
 *      offset or pointer to the body of a dynamic type. In calldata, the head
 *      is always an offset (relative to the parent object), while in memory,
 *      the head is always the pointer to the body. More information found here:
 *      https://docs.soliditylang.org/en/v0.8.13/abi-spec.html#argument-encoding
 *        - Note that the length of an array is separate from and precedes the
 *          head of the array.
 *
 *    - The term "pointer" is used to describe the absolute position of a value
 *      and never an offset relative to another value.
 *        - The suffix "_ptr" refers to a memory pointer.
 *
 *    - The term "offset" is used to describe the position of a value relative
 *      to some parent value. For example, ERC1155_safeTransferFrom_data_offset_ptr
 *      is the offset to the "data" value in the parameters for an ERC1155
 *      safeTransferFrom call relative to the start of the body.
 *        - Note: Offsets are used to derive pointers.
 */

// abi.encodeWithSignature("transfer(address,uint256)")
uint256 constant ERC20_TRANSFER_SIGNATURE = (
    0xa9059cbb00000000000000000000000000000000000000000000000000000000
);
uint256 constant ERC20_TRANSFER_SIG_PTR = 0x00;
uint256 constant ERC20_TRANSFER_TO_PTR = 0x04;
uint256 constant ERC20_TRANSFER_AMOUNT_PTR = 0x24;
uint256 constant ERC20_TRANSFER_LENGTH = 0x44; // 4 + 32 * 2 == 68

// abi.encodeWithSignature("transferFrom(address,address,uint256)")
uint256 constant ERC721_TRANSFER_FROM_SIGNATURE = (
    0x23b872dd00000000000000000000000000000000000000000000000000000000
);
uint256 constant ERC721_TRANSFER_SIG_PTR = 0x00;
uint256 constant ERC721_TRANSFER_FROM_PTR = 0x04;
uint256 constant ERC721_TRANSFER_TO_PTR = 0x24;
uint256 constant ERC721_TRANSFER_ID_PTR = 0x44;
uint256 constant ERC721_TRANSFER_LENGTH = 0x64; // 4 + 32 * 3 == 100

// abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)")
uint256 constant ERC1155_SAFE_TRANSFER_FROM_signature = (
    0xf242432a00000000000000000000000000000000000000000000000000000000
);
uint256 constant ERC1155_SAFE_TRANSFER_SIG_PTR = 0x00;
uint256 constant ERC1155_SAFE_TRANSFER_FROM_PTR = 0x04;
uint256 constant ERC1155_SAFE_TRANSFER_TO_PTR = 0x24;
uint256 constant ERC1155_SAFE_TRANSFER_ID_PTR = 0x44;
uint256 constant ERC1155_SAFE_TRANSFER_AMOUNT_PTR = 0x64;
uint256 constant ERC1155_SAFE_TRANSFER_DATA_OFFSET_PTR = 0x84;
uint256 constant ERC1155_SAFE_TRANSFER_DATA_LENGTH_PTR = 0xa4;
uint256 constant ERC1155_SAFE_TRANSFER_LENGTH = 0xc4; // 4 + 32 * 6 == 196
uint256 constant ERC1155_SAFE_TRANSFER_DATA_LENGTH_OFFSET = 0xa0;

// abi.encodeWithSignature("safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)")
uint256 constant ERC1155_SAFE_BATCH_TRANSFER_FROM_SIGNATURE = (
    0x2eb2c2d600000000000000000000000000000000000000000000000000000000
);
// Values are offset by 32 bytes in order to write the token to the beginning in the event of a revert
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_PTR = 0x24;
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_IDS_HEAD_PTR = 0x44;
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_AMOUNTS_HEAD_PTR = 0x84;
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_DATA_HEAD_PTR = 0xa4;
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_DATA_LENGTH_BASE_PTR = 0x104;
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_IDS_LENGTH_PTR = 0xc4;
uint256 constant ERC1155_BATCH_TRANSFER_PARAMS_IDS_LENGTH_OFFSET = 0xa0;

uint256 constant ERC1155_BATCH_TRANSFER_USABLE_HEAD_SIZE = 0x80;

uint256 constant ERC1155_BATCH_TRANSFER_FROM_OFFSET = 0x20;
uint256 constant ERC1155_BATCH_TRANSFER_IDS_HEAD_OFFSET = 0x60;
uint256 constant ERC1155_BATCH_TRANSFER_AMOUNTS_HEAD_OFFSET = 0x80;
uint256 constant ERC1155_BATCH_TRANSFER_IDS_LENGTH_OFFSET = 0xa0;
uint256 constant ERC1155_BATCH_TRANSFER_AMOUNTS_LENGTH_BASE_OFFSET = 0xc0;
uint256 constant ERC1155_BATCH_TRANSFER_CALLDATA_BASE_SIZE = 0xc0;

// ERRORS

// abi.encodeWithSignature("BadReturnValueFromERC20OnTransfer(address,address,address,uint256)")
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_SIGNATURE = (
    0x9889192300000000000000000000000000000000000000000000000000000000
);
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_SIG_PTR = 0x00;
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_TOKEN_PTR = 0x04;
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_FROM_PTR = 0x24;
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_TO_PTR = 0x44;
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_AMOUNT_PTR = 0x64;
uint256 constant BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_LENGTH = 0x84; // 4 + 32 * 4 == 132

// abi.encodeWithSignature("ERC1155BatchTransferGenericFailure(address)")
uint256 constant ERC1155_BATCH_TRANSFER_GENERIC_FAILURE_ERROR_SIGNATURE = (
    0xafc445e200000000000000000000000000000000000000000000000000000000
);
uint256 constant ERC1155_BATCH_TRANSFER_GENERIC_FAILURE_TOKEN_PTR = 0x04;

uint256 constant INVALID_1155_BATCH_TRANSFER_ENCODING_SELECTOR = (
    0xeba2084c00000000000000000000000000000000000000000000000000000000
);
uint256 constant INVALID_1155_BATCH_TRANSFER_ENCODING_PTR = 0x00;
uint256 constant INVALID_1155_BATCH_TRANSFER_ENCODING_LENGTH = 0x04;

// abi.encodeWithSignature("NoContract(address)")
uint256 constant NO_CONTRACT_ERROR_SIGNATURE = (
    0x5f15d67200000000000000000000000000000000000000000000000000000000
);
uint256 constant NO_CONTRACT_ERROR_SIG_PTR = 0x00;
uint256 constant NO_CONTRACT_ERROR_TOKEN_PTR = 0x04;
uint256 constant NO_CONTRACT_ERROR_LENGTH = 0x24; // 4 + 32 == 36

// abi.encodeWithSignature("TokenTransferGenericFailure(address,address,address,uint256,uint256)")
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIGNATURE = (
    0xf486bc8700000000000000000000000000000000000000000000000000000000
);
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR = 0x00;
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TOKEN_PTR = 0x04;
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_FROM_PTR = 0x24;
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TO_PTR = 0x44;
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_ID_PTR = 0x64;
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_AMOUNT_PTR = 0x84;
uint256 constant TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_LENGTH = 0xa4; // 4 + 32 * 5 == 164
