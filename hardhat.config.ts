import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv"

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "calibration",
  solidity: "0.8.20",
  networks: {
    hardhat: {},
    calibration: {
      url: "https://api.calibration.node.glif.io/rpc/v1",
      accounts: [process.env.ACCOUNT_PRIVATE_KEY as string],
    }
  },
  paths: {
    sources: "./contracts",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;