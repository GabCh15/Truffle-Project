const Linux = artifacts.require('Linux')
const Windows = artifacts.require('Windows')
const Staking = artifacts.require('Staking')

module.exports = async function (deployer) {
    await deployer.deploy(Linux)
    await deployer.deploy(Windows, Linux.address)
    await deployer.deploy(Staking, Linux.address)
}
