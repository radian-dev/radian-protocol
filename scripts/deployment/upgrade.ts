const { ethers, upgrades } = require("hardhat");

async function upgrade(
    contractName = process.env.TARGET,
    proxyAddress = process.env.PROXY
) {
    // We get the contract to upgrade
    const ContractV2 = await ethers.getContractFactory(contractName);
    const Contractv2 = await upgrades.upgradeProxy(proxyAddress, ContractV2);
    
    console.log("Contractis", Contractv2.address);
    console.log("ContractImplementationAddress is",await upgrades.erc1967.getImplementationAddress(Contractv2.address));
    console.log("ContractAdminAddress is",await upgrades.erc1967.getAdminAddress(Contractv2.address) );
  
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  upgrade().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  