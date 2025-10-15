const hre = require('hardhat');
require('@nomicfoundation/hardhat-ethers'); // 👈 make sure this is included

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const tokenAddress = 'TOKEN_ADDRESS'; // Replace with actual token
  const usdcTokenAddress = 'USDC_ADDRESS';

  console.log('Deploying from:', deployer.address);

  const Contract = await hre.ethers.getContractFactory('CustodialWallet');
  const contract = await Contract.deploy(usdcTokenAddress, tokenAddress);

  const deployedContract = await contract.waitForDeployment();

  const deployedAddress = await deployedContract.getAddress();

  console.log('Contract deployed at:', deployedAddress);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
