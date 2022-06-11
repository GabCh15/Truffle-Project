const Linux = artifacts.require('Linux')
const Windows = artifacts.require('Windows')

module.exports = async function (deployer) {
    let linux = await Linux.new()
    await Windows.new(linux.address)
    await LinuxStaking.new(linux.address)
}
