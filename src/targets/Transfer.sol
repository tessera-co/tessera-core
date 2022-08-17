// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ITransfer} from "../interfaces/ITransfer.sol";
import "../constants/Transfer.sol";

/// @title Transfer
/// @author Fractional Art
/// @notice Target contract for transferring fungible and non-fungible tokens
contract Transfer is ITransfer {
    /// @notice Transfers an ERC-20 token
    /// @param _token Address of the token
    /// @param _to Target address
    /// @param _amount Transfer amount
    function ERC20Transfer(
        address _token,
        address _to,
        uint256 _amount
    ) external {
        // Utilize assembly to perform an optimized ERC20 token transfer.
        assembly {
            // Write calldata to the free memory pointer, but restore it later.
            let memPointer := mload(FREE_MEMORY_POINTER_SLOT)

            // Write calldata into memory, starting with function selector.
            mstore(ERC20_TRANSFER_SIG_PTR, ERC20_TRANSFER_SIGNATURE)
            mstore(ERC20_TRANSFER_TO_PTR, _to) // Append the "_to" argument.
            mstore(ERC20_TRANSFER_AMOUNT_PTR, _amount) // Append the "_amount" argument.

            // Make call & copy up to 32 bytes of return data to scratch space.
            // Scratch space does not need to be cleared ahead of time, as the
            // subsequent check will ensure that either at least a full word of
            // return data is received (in which case it will be overwritten) or
            // that no data is received (in which case scratch space will be
            // ignored) on a successful call to the given token.
            let callStatus := call(
                gas(),
                _token,
                0,
                ERC20_TRANSFER_SIG_PTR,
                ERC20_TRANSFER_LENGTH,
                0,
                ONE_WORD
            )

            // Determine whether transfer was successful using status & result.
            let success := and(
                // Set success to whether the call reverted, if not check it
                // either returned exactly 1 (can't just be non-zero data), or
                // had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                callStatus
            )

            // If the transfer failed or it returned nothing:
            // Group these because they should be uncommon.
            // Equivalent to `or(iszero(success), iszero(returndatasize()))`
            // but after it's inverted for JUMPI this expression is cheaper.
            if iszero(and(success, iszero(iszero(returndatasize())))) {
                // If the token has no code or the transfer failed:
                // Equivalent to `or(iszero(success), iszero(extcodesize(token)))`
                // but after it's inverted for JUMPI this expression is cheaper.
                if iszero(and(iszero(iszero(extcodesize(_token))), success)) {
                    if iszero(success) {
                        // If it was due to a revert:
                        if iszero(callStatus) {
                            // If it returned a message, bubble it up as long as
                            // sufficient gas remains to do so:
                            if returndatasize() {
                                // Ensure that sufficient gas is available to
                                // copy returndata while expanding memory where
                                // necessary. Start by computing the word size
                                // of returndata and allocated memory.
                                let returnDataWords := div(
                                    add(returndatasize(), ALMOST_ONE_WORD),
                                    ONE_WORD
                                )

                                // Note: use the free memory pointer in place of
                                // msize() to work around a Yul warning that
                                // prevents accessing msize directly when the IR
                                // pipeline is activated.
                                let msizeWords := div(memPointer, ONE_WORD)

                                // Next, compute the cost of the returndatacopy.
                                let cost := mul(COST_PER_WORD, returnDataWords)

                                // Then, compute cost of new memory allocation.
                                if gt(returnDataWords, msizeWords) {
                                    cost := add(
                                        cost,
                                        add(
                                            mul(
                                                sub(
                                                    returnDataWords,
                                                    msizeWords
                                                ),
                                                COST_PER_WORD
                                            ),
                                            div(
                                                sub(
                                                    mul(
                                                        returnDataWords,
                                                        returnDataWords
                                                    ),
                                                    mul(msizeWords, msizeWords)
                                                ),
                                                MEMORY_EXPANSION_COEFFICIENT
                                            )
                                        )
                                    )
                                }

                                // Finally, add a small constant and compare to
                                // gas remaining; bubble up the revert data if
                                // enough gas is still available.
                                if lt(add(cost, EXTRA_GAS_BUFFER), gas()) {
                                    // Copy returndata to memory; overwrite
                                    // existing memory.
                                    returndatacopy(0, 0, returndatasize())

                                    // Revert, specifying memory region with
                                    // copied returndata.
                                    revert(0, returndatasize())
                                }
                            }

                            // Otherwise revert with a generic error message.
                            mstore(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR,
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIGNATURE
                            )
                            mstore(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TOKEN_PTR,
                                _token
                            )
                            // replace "from" argument with msg.sender
                            mstore(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_FROM_PTR,
                                caller()
                            )
                            mstore(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TO_PTR,
                                _to
                            )
                            mstore(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_ID_PTR,
                                0
                            )
                            mstore(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_AMOUNT_PTR,
                                _amount
                            )
                            revert(
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR,
                                TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_LENGTH
                            )
                        }

                        // Otherwise revert with a message about the token
                        // returning false.
                        mstore(
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_SIG_PTR,
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_SIGNATURE
                        )
                        mstore(
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_TOKEN_PTR,
                            _token
                        )
                        // replace "from" argument with msg.sender
                        mstore(
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_FROM_PTR,
                            caller()
                        )
                        mstore(
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_TO_PTR,
                            _to
                        )
                        mstore(
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_AMOUNT_PTR,
                            _amount
                        )
                        revert(
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_SIG_PTR,
                            BAD_RETURN_VALUE_FROM_ERC20_ON_TRANSFER_ERROR_LENGTH
                        )
                    }

                    // Otherwise revert with error about token not having code:
                    mstore(
                        NO_CONTRACT_ERROR_SIG_PTR,
                        NO_CONTRACT_ERROR_SIGNATURE
                    )
                    mstore(NO_CONTRACT_ERROR_TOKEN_PTR, _token)
                    revert(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_LENGTH)
                }

                // Otherwise the token just returned nothing but otherwise
                // succeeded; no need to optimize for this as it's not
                // technically ERC20 compliant.
            }

            // Restore the original free memory pointer.
            mstore(FREE_MEMORY_POINTER_SLOT, memPointer)

            // Restore the zero slot to zero.
            mstore(ZERO_SLOT, 0)
        }
    }

    /// @notice Transfers an ERC-721 token
    /// @param _token Address of the token
    /// @param _from Source address
    /// @param _to Target address
    /// @param _tokenId ID of the token
    function ERC721TransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        // Utilize assembly to perform an optimized ERC721 token transfer.
        assembly {
            // If the token has no code, revert.
            if iszero(extcodesize(_token)) {
                mstore(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_SIGNATURE)
                mstore(NO_CONTRACT_ERROR_TOKEN_PTR, _token)
                revert(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_LENGTH)
            }

            // Write calldata to free memory pointer (restore it later).
            let memPointer := mload(FREE_MEMORY_POINTER_SLOT)

            // Write calldata to memory starting with function selector.
            mstore(ERC721_TRANSFER_SIG_PTR, ERC721_TRANSFER_FROM_SIGNATURE)
            mstore(ERC721_TRANSFER_FROM_PTR, _from)
            mstore(ERC721_TRANSFER_TO_PTR, _to)
            mstore(ERC721_TRANSFER_ID_PTR, _tokenId)

            // Perform the call, ignoring return data.
            let success := call(
                gas(),
                _token,
                0,
                ERC721_TRANSFER_SIG_PTR,
                ERC721_TRANSFER_LENGTH,
                0,
                0
            )

            // If the transfer reverted:
            if iszero(success) {
                // If it returned a message, bubble it up as long as sufficient
                // gas remains to do so:
                if returndatasize() {
                    // Ensure that sufficient gas is available to copy
                    // returndata while expanding memory where necessary. Start
                    // by computing word size of returndata & allocated memory.
                    // Round up to the nearest full word.
                    let returnDataWords := div(
                        add(returndatasize(), ALMOST_ONE_WORD),
                        ONE_WORD
                    )

                    // Note: use the free memory pointer in place of msize() to
                    // work around a Yul warning that prevents accessing msize
                    // directly when the IR pipeline is activated.
                    let msizeWords := div(memPointer, ONE_WORD)

                    // Next, compute the cost of the returndatacopy.
                    let cost := mul(COST_PER_WORD, returnDataWords)

                    // Then, compute cost of new memory allocation.
                    if gt(returnDataWords, msizeWords) {
                        cost := add(
                            cost,
                            add(
                                mul(
                                    sub(returnDataWords, msizeWords),
                                    COST_PER_WORD
                                ),
                                div(
                                    sub(
                                        mul(returnDataWords, returnDataWords),
                                        mul(msizeWords, msizeWords)
                                    ),
                                    MEMORY_EXPANSION_COEFFICIENT
                                )
                            )
                        )
                    }

                    // Finally, add a small constant and compare to gas
                    // remaining; bubble up the revert data if enough gas is
                    // still available.
                    if lt(add(cost, EXTRA_GAS_BUFFER), gas()) {
                        // Copy returndata to memory; overwrite existing memory.
                        returndatacopy(0, 0, returndatasize())

                        // Revert, giving memory region with copied returndata.
                        revert(0, returndatasize())
                    }
                }

                // Otherwise revert with a generic error message.
                mstore(
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR,
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIGNATURE
                )
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TOKEN_PTR, _token)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_FROM_PTR, _from)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TO_PTR, _to)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_ID_PTR, _tokenId)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_AMOUNT_PTR, 1)
                revert(
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR,
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_LENGTH
                )
            }

            // Restore the original free memory pointer.
            mstore(FREE_MEMORY_POINTER_SLOT, memPointer)

            // Restore the zero slot to zero.
            mstore(ZERO_SLOT, 0)
        }
    }

    /// @notice Transfers an ERC-1155 token
    /// @param _token token to transfer
    /// @param _from Source address
    /// @param _to Target address
    /// @param _tokenId ID of the token type
    /// @param _amount Transfer amount
    function ERC1155TransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        // Utilize assembly to perform an optimized ERC1155 token transfer.
        assembly {
            // If the token has no code, revert.
            if iszero(extcodesize(_token)) {
                mstore(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_SIGNATURE)
                mstore(NO_CONTRACT_ERROR_TOKEN_PTR, _token)
                revert(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_LENGTH)
            }

            // Write calldata to these slots below, but restore them later.
            let memPointer := mload(FREE_MEMORY_POINTER_SLOT)
            let slot0x80 := mload(SLOT0x80)
            let slot0xA0 := mload(SLOT0xA0)
            let slot0xC0 := mload(SLOT0xC0)

            // Write calldata into memory, beginning with function selector.
            mstore(
                ERC1155_SAFE_TRANSFER_SIG_PTR,
                ERC1155_SAFE_TRANSFER_FROM_signature
            )
            mstore(ERC1155_SAFE_TRANSFER_FROM_PTR, _from)
            mstore(ERC1155_SAFE_TRANSFER_TO_PTR, _to)
            mstore(ERC1155_SAFE_TRANSFER_ID_PTR, _tokenId)
            mstore(ERC1155_SAFE_TRANSFER_AMOUNT_PTR, _amount)
            mstore(
                ERC1155_SAFE_TRANSFER_DATA_OFFSET_PTR,
                ERC1155_SAFE_TRANSFER_DATA_LENGTH_OFFSET
            )
            mstore(ERC1155_SAFE_TRANSFER_DATA_LENGTH_PTR, 0)

            let success := call(
                gas(),
                _token,
                0,
                ERC1155_SAFE_TRANSFER_SIG_PTR,
                ERC1155_SAFE_TRANSFER_LENGTH,
                0,
                0
            )

            // If the transfer reverted:
            if iszero(success) {
                // If it returned a message, bubble it up as long as sufficient
                // gas remains to do so:
                if returndatasize() {
                    // Ensure that sufficient gas is available to copy
                    // returndata while expanding memory where necessary. Start
                    // by computing word size of returndata & allocated memory.
                    // Round up to the nearest full word.
                    let returnDataWords := div(
                        add(returndatasize(), ALMOST_ONE_WORD),
                        ONE_WORD
                    )

                    // Note: use the free memory pointer in place of msize() to
                    // work around a Yul warning that prevents accessing msize
                    // directly when the IR pipeline is activated.
                    let msizeWords := div(memPointer, ONE_WORD)

                    // Next, compute the cost of the returndatacopy.
                    let cost := mul(COST_PER_WORD, returnDataWords)

                    // Then, compute cost of new memory allocation.
                    if gt(returnDataWords, msizeWords) {
                        cost := add(
                            cost,
                            add(
                                mul(
                                    sub(returnDataWords, msizeWords),
                                    COST_PER_WORD
                                ),
                                div(
                                    sub(
                                        mul(returnDataWords, returnDataWords),
                                        mul(msizeWords, msizeWords)
                                    ),
                                    MEMORY_EXPANSION_COEFFICIENT
                                )
                            )
                        )
                    }

                    // Finally, add a small constant and compare to gas
                    // remaining; bubble up the revert data if enough gas is
                    // still available.
                    if lt(add(cost, EXTRA_GAS_BUFFER), gas()) {
                        // Copy returndata to memory; overwrite existing memory.
                        returndatacopy(0, 0, returndatasize())

                        // Revert, giving memory region with copied returndata.
                        revert(0, returndatasize())
                    }
                }

                // Otherwise revert with a generic error message.
                mstore(
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR,
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIGNATURE
                )
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TOKEN_PTR, _token)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_FROM_PTR, _from)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_TO_PTR, _to)
                mstore(TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_ID_PTR, _tokenId)
                mstore(
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_AMOUNT_PTR,
                    _amount
                )
                revert(
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_SIG_PTR,
                    TOKEN_TRANSFER_GENERTIC_FAILURE_ERROR_LENGTH
                )
            }

            mstore(SLOT0x80, slot0x80) // Restore slot 0x80.
            mstore(SLOT0xA0, slot0xA0) // Restore slot 0xA0.
            mstore(SLOT0xC0, slot0xC0) // Restore slot 0xC0.

            // Restore the original free memory pointer.
            mstore(FREE_MEMORY_POINTER_SLOT, memPointer)

            // Restore the zero slot to zero.
            mstore(ZERO_SLOT, 0)
        }
    }

    /// @notice Batch transfers multiple ERC-1155 tokens
    function ERC1155BatchTransferFrom(
        address, /*_token*/
        address, /*_from*/
        address, /*_to*/
        uint256[] calldata, /*_ids*/
        uint256[] calldata /*_amounts*/
    ) external {
        // Utilize assembly to perform an optimized ERC1155 batch transfer.
        assembly {
            // Write the function selector
            // safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)
            mstore(
                ERC1155_BATCH_TRANSFER_FROM_OFFSET,
                ERC1155_SAFE_BATCH_TRANSFER_FROM_SIGNATURE
            )

            // Retrieve the token from calldata.
            let token := calldataload(FOUR_BYTES)

            // If the token has no code, revert.
            if iszero(extcodesize(token)) {
                mstore(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_SIGNATURE)
                mstore(NO_CONTRACT_ERROR_TOKEN_PTR, token)
                revert(NO_CONTRACT_ERROR_SIG_PTR, NO_CONTRACT_ERROR_LENGTH)
            }

            // Get the total number of supplied ids.
            let idsLength := calldataload(
                add(FOUR_BYTES, ERC1155_BATCH_TRANSFER_IDS_LENGTH_OFFSET)
            )

            // Determine the expected offset for the amounts array.
            let expectedAmountsOffset := add(
                ERC1155_BATCH_TRANSFER_AMOUNTS_LENGTH_BASE_OFFSET,
                mul(idsLength, ONE_WORD)
            )

            // Validate struct encoding.
            let invalidEncoding := iszero(
                and(
                    // ids.length == amounts.length
                    eq(
                        idsLength,
                        calldataload(add(FOUR_BYTES, expectedAmountsOffset))
                    ),
                    and(
                        // ids_offset == 0xa0
                        eq(
                            calldataload(
                                add(
                                    FOUR_BYTES,
                                    ERC1155_BATCH_TRANSFER_IDS_HEAD_OFFSET
                                )
                            ),
                            ERC1155_BATCH_TRANSFER_IDS_LENGTH_OFFSET
                        ),
                        // amounts_offset == 0xc0 + ids.length*32
                        eq(
                            calldataload(
                                add(
                                    FOUR_BYTES,
                                    ERC1155_BATCH_TRANSFER_AMOUNTS_HEAD_OFFSET
                                )
                            ),
                            expectedAmountsOffset
                        )
                    )
                )
            )

            // Revert with an error if the encoding is not valid.
            if invalidEncoding {
                mstore(
                    INVALID_1155_BATCH_TRANSFER_ENCODING_PTR,
                    INVALID_1155_BATCH_TRANSFER_ENCODING_SELECTOR
                )
                revert(
                    INVALID_1155_BATCH_TRANSFER_ENCODING_PTR,
                    INVALID_1155_BATCH_TRANSFER_ENCODING_LENGTH
                )
            }

            // Copy the first 0x80 bytes after "token" from calldata into memory
            // at location BatchTransfer1155Params_ptr
            calldatacopy(
                ERC1155_BATCH_TRANSFER_PARAMS_PTR,
                add(FOUR_BYTES, ERC1155_BATCH_TRANSFER_FROM_OFFSET),
                ERC1155_BATCH_TRANSFER_USABLE_HEAD_SIZE
            )

            // Determine size of calldata required for ids and amounts. Note
            // that the size includes both lengths as well as the data.
            let idsAndAmountsSize := add(TWO_WORDS, mul(idsLength, TWO_WORDS))

            // Update the offset for the data array in memory.
            mstore(
                ERC1155_BATCH_TRANSFER_PARAMS_DATA_HEAD_PTR,
                add(
                    ERC1155_BATCH_TRANSFER_PARAMS_IDS_LENGTH_OFFSET,
                    idsAndAmountsSize
                )
            )

            // Set the length of the data array in memory to zero.
            mstore(
                add(
                    ERC1155_BATCH_TRANSFER_PARAMS_DATA_LENGTH_BASE_PTR,
                    idsAndAmountsSize
                ),
                0
            )

            // Determine the total calldata size for the call to transfer.
            let transferDataSize := add(
                ERC1155_BATCH_TRANSFER_PARAMS_DATA_LENGTH_BASE_PTR,
                idsAndAmountsSize
            )

            // Copy second section of calldata (including dynamic values).
            calldatacopy(
                ERC1155_BATCH_TRANSFER_PARAMS_IDS_LENGTH_PTR,
                add(
                    FOUR_BYTES,
                    ERC1155_BATCH_TRANSFER_PARAMS_IDS_LENGTH_OFFSET
                ),
                idsAndAmountsSize
            )

            // Perform the call to transfer 1155 tokens.
            let success := call(
                gas(),
                token,
                0,
                ERC1155_BATCH_TRANSFER_FROM_OFFSET, // Data portion start.
                transferDataSize, // Location of the length of callData.
                0,
                0
            )

            // If the transfer reverted:
            if iszero(success) {
                // If it returned a message, bubble it up as long as
                // sufficient gas remains to do so:
                if returndatasize() {
                    // Ensure that sufficient gas is available to copy
                    // returndata while expanding memory where necessary.
                    // Start by computing word size of returndata and
                    // allocated memory.
                    let returnDataWords := div(
                        add(returndatasize(), ALMOST_ONE_WORD),
                        ONE_WORD
                    )

                    // Note: use transferDataSize in place of msize() to
                    // work around a Yul warning that prevents accessing
                    // msize directly when the IR pipeline is activated.
                    // The free memory pointer is not used here because
                    // this function does almost all memory management
                    // manually and does not update it, and transferDataSize
                    // should be the largest memory value used (unless a
                    // previous batch was larger).
                    let msizeWords := div(transferDataSize, ONE_WORD)

                    // Next, compute the cost of the returndatacopy.
                    let cost := mul(COST_PER_WORD, returnDataWords)

                    // Then, compute cost of new memory allocation.
                    if gt(returnDataWords, msizeWords) {
                        cost := add(
                            cost,
                            add(
                                mul(
                                    sub(returnDataWords, msizeWords),
                                    COST_PER_WORD
                                ),
                                div(
                                    sub(
                                        mul(returnDataWords, returnDataWords),
                                        mul(msizeWords, msizeWords)
                                    ),
                                    MEMORY_EXPANSION_COEFFICIENT
                                )
                            )
                        )
                    }

                    // Finally, add a small constant and compare to gas
                    // remaining; bubble up the revert data if enough gas is
                    // still available.
                    if lt(add(cost, EXTRA_GAS_BUFFER), gas()) {
                        // Copy returndata to memory; overwrite existing.
                        returndatacopy(0, 0, returndatasize())

                        // Revert with memory region containing returndata.
                        revert(0, returndatasize())
                    }
                }

                // Set the error signature.
                mstore(
                    0,
                    ERC1155_BATCH_TRANSFER_GENERIC_FAILURE_ERROR_SIGNATURE
                )

                // Write the token.
                mstore(ERC1155_BATCH_TRANSFER_GENERIC_FAILURE_TOKEN_PTR, token)

                // Move the ids and amounts offsets forward a word.
                mstore(
                    ERC1155_BATCH_TRANSFER_PARAMS_IDS_HEAD_PTR,
                    ERC1155_BATCH_TRANSFER_AMOUNTS_HEAD_OFFSET
                )
                mstore(
                    ERC1155_BATCH_TRANSFER_PARAMS_AMOUNTS_HEAD_PTR,
                    add(
                        ONE_WORD,
                        mload(ERC1155_BATCH_TRANSFER_PARAMS_AMOUNTS_HEAD_PTR)
                    )
                )

                // Return modified region with one fewer word at the end.
                revert(0, transferDataSize)
            }

            // Reset the free memory pointer to the default value; memory must
            // be assumed to be dirtied and not reused from this point forward.
            mstore(FREE_MEMORY_POINTER_SLOT, DEFAULT_FREE_MEMORY_POINTER_SLOT)
        }
    }
}
