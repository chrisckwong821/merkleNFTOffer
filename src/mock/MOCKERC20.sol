// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/token/ERC20/ERC20.sol";

contract MOCKERC20 is ERC20 {

    constructor() ERC20("MOCKERC20", "MOCKERC20") {}
    function mint(address account, uint256 amount) external {
        require(account != address(0), "Account is empty.");
        require(amount > 0, "amount is less than zero.");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(account != address(0), "Account is empty.");
        require(amount > 0, "amount is less than zero.");
        _burn(account, amount);
    }
}