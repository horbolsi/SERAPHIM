// scripts/deployLiquidityToken.js
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy LiquidityToken contract
    const LiquidityToken = await ethers.getContractFactory("LiquidityToken");
    const liquidityToken = await LiquidityToken.deploy();
    await liquidityToken.deployed();

    console.log("LiquidityToken deployed to:", liquidityToken.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

