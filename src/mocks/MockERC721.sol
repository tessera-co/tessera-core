// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@rari-capital/solmate/src/tokens/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("TEST_Token", "TEST") {}

    function tokenURI(uint256)
        public
        pure
        virtual
        override
        returns (string memory)
    {
        return "";
    }

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);
    }
}
