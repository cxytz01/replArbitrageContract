const hre = require("hardhat");

async function main() {
    const swapContractAddress = "0x66277CF22f4a5069Dd0460F5a44EFf9D0c391E76";
    const replAuctionAddress = "0x75300F6C5620b4161Fc0729b83cFFE72BdDE62C4";
    const pFILTokenAddress = "0xADD77Cb736Db6F4223776A3E4b173657D0d7F8c8";

    const ArbitrageBot = await hre.ethers.getContractFactory("ArbitrageBot");

    const arbitrageBot = await ArbitrageBot.deploy(
        swapContractAddress,
        replAuctionAddress,
        pFILTokenAddress
    );

    await arbitrageBot.waitForDeployment();

    console.log(
        `ArbitrageBot contract deployed to https://calibration.filfox.info/en/address/${arbitrageBot.target}`
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

