// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import {SafeSend} from "../utils/SafeSend.sol";

contract MockSender is SafeSend {
    function sendEthOrWeth(address to, uint256 value) external {
        _sendEthOrWeth(to, value);
    }

    receive() external payable {}
}
