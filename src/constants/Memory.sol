// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

uint256 constant COST_PER_WORD = 3;

uint256 constant ONE_WORD = 0x20;
uint256 constant ALMOST_ONE_WORD = 0x1f;
uint256 constant TWO_WORDS = 0x40;

uint256 constant FREE_MEMORY_POINTER_SLOT = 0x40;
uint256 constant ZERO_SLOT = 0x60;
uint256 constant DEFAULT_FREE_MEMORY_POINTER_SLOT = 0x80;

uint256 constant SLOT0x80 = 0x80;
uint256 constant SLOT0xA0 = 0xa0;
uint256 constant SLOT0xC0 = 0xc0;

uint256 constant FOUR_BYTES = 0x04;
uint256 constant EXTRA_GAS_BUFFER = 0x20;
uint256 constant MEMORY_EXPANSION_COEFFICIENT = 0x200;
