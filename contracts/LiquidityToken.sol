// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract LiquidityToken is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    uint256 public constant INITIAL_SUPPLY = 8888888888888 * 10**18;

    function initialize() public initializer {
        __ERC20_init("LiquidityToken", "LTK");
        __Ownable_init();
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // Function to mint additional tokens (if needed)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens (if needed)
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }
}

