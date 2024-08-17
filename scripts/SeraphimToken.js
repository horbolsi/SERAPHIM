// scripts/deploySeraphimToken.js
const { ethers, upgrades } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy LiquidityToken first to obtain its address
    const LiquidityToken = await ethers.getContractFactory("LiquidityToken");
    const liquidityToken = await LiquidityToken.deploy();
    await liquidityToken.deployed();

    console.log("LiquidityToken deployed to:", liquidityToken.address);

    // Deploy Governance contract
    const Governance = await ethers.getContractFactory("Governance");
    const governance = await Governance.deploy();
    await governance.deployed();

    console.log("Governance contract deployed to:", governance.address);

    // Deploy SeraphimToken contract
    const SeraphimToken = await ethers.getContractFactory("SeraphimToken");
    const seraphimToken = await upgrades.deployProxy(SeraphimToken, [deployer.address, liquidityToken.address, governance.address, deployer.address], { initializer: 'initialize' });
    await seraphimToken.deployed();

    console.log("SeraphimToken deployed to:", seraphimToken.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

