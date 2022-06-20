// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers, upgrades } = require("hardhat");
import { setContractEnvValue, log } from "../utils";

export async function deploy_upgradeable(
  contractName = process.env.TARGET,
  params: any[] = [],
  logLevel: number = 1
) {
    
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await upgrades.deployProxy(Contract, params);
  await contract.deployed();
  
  log(logLevel, contractName + " Contractis " + contract.address);
  log(logLevel, contractName + " ContractImplementationAddress is " + (await upgrades.erc1967.getImplementationAddress(contract.address)));
  log(logLevel, contractName + " ContractAdminAddress is " + (await upgrades.erc1967.getAdminAddress(contract.address)));
  
  // set env var
  setContractEnvValue(contractName?.toUpperCase() + "_CONTRACT", contract.address);
  log(logLevel, contractName + " Contractis " + contract.address);

  return contract;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deploy_upgradeable().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
