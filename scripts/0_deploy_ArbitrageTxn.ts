const hre = require("hardhat");

async function main() {
    const swapContractAddress = "0x66277CF22f4a5069Dd0460F5a44EFf9D0c391E76";
    const replAuctionAddress = "0x75300F6C5620b4161Fc0729b83cFFE72BdDE62C4";
    const pFILTokenAddress = "0xADD77Cb736Db6F4223776A3E4b173657D0d7F8c8";
    const wpFILTokenAddress = "0x07961742e79Cecf1171d2D5050ca489572C61384";
    const uniswapPool = "0x957378327F43392B74519dD7F734e68039a64074";

    const ArbitrageBot = await hre.ethers.getContractFactory("ArbitrageBot");

    const arbitrageBot = await ArbitrageBot.deploy(
        swapContractAddress,
        replAuctionAddress,
        pFILTokenAddress,
        wpFILTokenAddress,
        uniswapPool
    );

    await arbitrageBot.waitForDeployment();

    console.log(
        `ArbitrageBot contract deployed to https://fvm.starboard.ventures/calibration/explorer/address/${arbitrageBot.target}`
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

