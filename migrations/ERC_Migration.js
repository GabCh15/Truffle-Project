const Linux = artifacts.require('Linux')
const Windows = artifacts.require('Windows')

module.exports = async function (deployer) {
    await deployer.deploy(Linux)
    await deployer.deploy(Windows, Linux.address)
}
