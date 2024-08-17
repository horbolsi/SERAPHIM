const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("SeraphimToken", function () {
    let SeraphimToken;
    let token;
    let deployer;
    let addr1;

    beforeEach(async function () {
        [deployer, addr1] = await ethers.getSigners();
        SeraphimToken = await ethers.getContractFactory("SeraphimToken");
        token = await upgrades.deployProxy(SeraphimToken, [
            deployer.address,
            "0xYourLiquidityTokenAddress",
            "0xYourGovernanceContractAddress",
            deployer.address
        ]);
    });

    it("Should deploy correctly", async function () {
        expect(await token.name()).to.equal("Seraphim");
        expect(await token.symbol()).to.equal("SRP");
    });

    // Add more tests as needed
});

