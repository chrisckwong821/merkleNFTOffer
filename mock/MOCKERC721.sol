// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/token/ERC721/ERC721.sol";

contract MOCKERC721 is ERC721 {

    constructor() ERC721("MOCKCollection", "MOCKCollection") {}
    function mint(address account, uint256 tokenId) external {
        require(account != address(0), "Account is empty.");
        _mint(account, tokenId);
    }
}