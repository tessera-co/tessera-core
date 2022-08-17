// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract MockEthReceiver {
    receive() external payable {}
}

contract MockEthNotReceiver {
    receive() external payable {
        revert();
    }
}
