// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {

  /// deploy the NFT  contract
  const nftContract = await 
  hre.ethers.deployContract("CryptoDevsNFT");
  await nftContract.waitForDeployment();
  console.log("CryptoDevsNFT deployed to:", nftContract.target);

  // deploy the FAKE marketplace contract

  const fakeMarketplaceContract = await hre.ethers.deployContract(
    "FakeMarketplace"
  );

  await fakeMarketplaceContract.waitForDeployment(); // here we wait for the deployment
  console.log(
    "fakeNFTMarketplace deployed to:", fakeMarketplaceContract.target
  );// this is the address of the marketplace contract

  // deploy the DAO  contract

  const daoContract = await 
  hre.ethers.deployContract("CryptoDevsDAO", [fakeMarketplaceContract.target, nftContract.target])// here we deploy the DAO contract
  await daoContract.waitForDeployment();
  console.log("CryptoDevsDAO deployed to:", daoContract.target);// the address of the DAO contract


  // sleep for 30 seconds to let etherscan catchup with the deployments
  await sleep(30 * 1000);

  //verify the NFT Contract
  await hre.run("verify:verify", {
    address: nftContract.target, 
    constructorArguments: [],
  })

  // verify the Fake Market place Contract

  await hre.run("verify:verify", {
    address: fakeMarketplaceContract.target,
    constructorArguments: [],
  })

  // verify the DAO  contract

  await hre.run("verify:verify", {
    address: daoContract.target,
    constructorArguments: [
      fakeMarketplaceContract.target,
      nftContract.target
    ]
  })



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
