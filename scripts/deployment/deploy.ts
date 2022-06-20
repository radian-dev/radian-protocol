// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");
import { setContractEnvValue, log } from "../utils";

export async function deploy(
  contractName = process.env.TARGET,
  params: any[] = [],
  logLevel = 1
) {

  // We get the contract to deploy
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(...params);
  log(logLevel, contractName + " Contractis " + contract.address);
  
  // set env var
  setContractEnvValue(contractName?.toUpperCase() + "_CONTRACT", contract.address);
  log(logLevel, contractName + " Contractis "+ contract.address);
  
  return contract;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
