// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SERAPHIM is ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint256 public burnFee; // Burn fee percentage (in basis points)
    uint256 public poolFee; // Investment pool fee percentage (in basis points)
    uint256 public redisFee; // Redistribution fee percentage (in basis points)
    uint256 public liquidityFee; // Liquidity fee percentage (in basis points)

    address public investmentPool; // Address of the investment pool
    address public redistributor; // Address for redistribution
    address public liquidityPool; // Address for liquidity

    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedBNB;

    event FeesUpdated(uint256 burnFee, uint256 poolFee, uint256 redisFee, uint256 liquidityFee);
    event InvestmentPoolUpdated(address newPool);
    event RedistributorUpdated(address newRedistributor);
    event LiquidityPoolUpdated(address newLiquidityPool);

    function initialize() public initializer {
        __ERC20_init("SERAPHIM", "SRP");
        __Ownable_init();
        __ReentrancyGuard_init(); // Initialize ReentrancyGuard

        _mint(msg.sender, 8888888888888 * 10 ** decimals());

        // Initialize fees to 1% each
        burnFee = 100; // 1%
        poolFee = 100; // 1%
        redisFee = 100; // 1%
        liquidityFee = 100; // 1%

        // Initialize Chainlink price feeds (correct checksummed addresses)
        priceFeedETH = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH/USD price feed (Ethereum Mainnet)
        priceFeedBNB = AggregatorV3Interface(0x0567F2323251F0aaB15c8Dfb1967E4e03A8d08D4); // BNB/USD price feed (Binance Smart Chain Mainnet)
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // External setters for fee parameters
    function setBurnFee(uint256 _burnFee) external onlyOwner {
        require(_burnFee <= 1000, "Fee too high"); // Max 10%
        burnFee = _burnFee;
        emit FeesUpdated(burnFee, poolFee, redisFee, liquidityFee);
    }

    function setPoolFee(uint256 _poolFee) external onlyOwner {
        require(_poolFee <= 1000, "Fee too high"); // Max 10%
        poolFee = _poolFee;
        emit FeesUpdated(burnFee, poolFee, redisFee, liquidityFee);
    }

    function setRedisFee(uint256 _redisFee) external onlyOwner {
        require(_redisFee <= 1000, "Fee too high"); // Max 10%
        redisFee = _redisFee;
        emit FeesUpdated(burnFee, poolFee, redisFee, liquidityFee);
    }

    function setLiquidityFee(uint256 _liquidityFee) external onlyOwner {
        require(_liquidityFee <= 1000, "Fee too high"); // Max 10%
        liquidityFee = _liquidityFee;
        emit FeesUpdated(burnFee, poolFee, redisFee, liquidityFee);
    }

    // External setters for addresses
    function setInvestmentPool(address _pool) external onlyOwner {
        investmentPool = _pool;
        emit InvestmentPoolUpdated(_pool);
    }

    function setRedistributor(address _redistributor) external onlyOwner {
        redistributor = _redistributor;
        emit RedistributorUpdated(_redistributor);
    }

    function setLiquidityPool(address _liquidityPool) external onlyOwner {
        liquidityPool = _liquidityPool;
        emit LiquidityPoolUpdated(_liquidityPool);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 burnAmount = amount * burnFee / 10000;
        uint256 poolAmount = amount * poolFee / 10000;
        uint256 redisAmount = amount * redisFee / 10000;
        uint256 liquidityAmount = amount * liquidityFee / 10000;
        uint256 netAmount = amount - burnAmount - poolAmount - redisAmount - liquidityAmount;

        super._transfer(sender, recipient, netAmount);

        if (burnAmount > 0) {
            _burn(sender, burnAmount);
        }

        if (poolAmount > 0 && investmentPool != address(0)) {
            super._transfer(sender, investmentPool, poolAmount);
        }

        if (redisAmount > 0 && redistributor != address(0)) {
            super._transfer(sender, redistributor, redisAmount);
        }

        if (liquidityAmount > 0 && liquidityPool != address(0)) {
            super._transfer(sender, liquidityPool, liquidityAmount);
        }
    }

    // Functions to get price feeds
    function getLatestPriceETH() public view returns (int) {
        (, int price, , ,) = priceFeedETH.latestRoundData();
        return price;
    }

    function getLatestPriceBNB() public view returns (int) {
        (, int price, , ,) = priceFeedBNB.latestRoundData();
        return price;
    }

    // Optional function for cross-chain interactions
    function handleCrossChainTransfer() external onlyOwner nonReentrant {
        // Placeholder for cross-chain transfer logic
        require(false, "Cross-chain transfer not implemented.");
    }
}

