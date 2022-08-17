// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@rari-capital/solmate/src/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("TEST_Token", "TEST", 18) {}

    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public virtual {
        _burn(from, amount);
    }
}
