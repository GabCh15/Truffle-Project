const Linux = artifacts.require("Linux");
const Staking = artifacts.require("Staking");

module.exports = async function (deployer) {
  await deployer.deploy(Linux);
  await deployer.deploy(Staking,Linux.address);
};
