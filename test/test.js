var assert = require('assert')
const Linux = artifacts.require('Linux')
const LinuxStaking = artifacts.require('LinuxStaking')
const Windows = artifacts.require('Windows')

let linux, windows, linuxStaking

beforeEach(async () => {
    linux = await Linux.new()
    windows = await Windows.new(linux.address)
    linuxStaking = await LinuxStaking.new(linux.address)
})

contract('Windows', (accounts) => {
    let currentAddress = accounts[0]
    it('Windows should mint multiple tokens', async () => {
        await linux.sendTransaction({ value: 1000 })
        await linux.approve(windows.address, 1000)
        console.log((await windows.mintMultipleTokens(2)).logs[0].args)
        assert.equal(
            await windows.balanceOf(currentAddress),
            2,
            'User has not 2 NFTs'
        )
    })
    it('Windows should not mint any token', async () => {
        await linux.sendTransaction({ value: 1000 })
        await linux.approve(windows.address, 1000)
        await windows.setIsMintEnabled(false)
        try {
            console.log(await windows.mintToken())
        } catch (e) {
            console.log(e)
        }

        assert.equal(
            await windows.balanceOf(currentAddress),
            0,
            'User minted succesfully'
        )
    })
})

contract('LinuxStaking', (accounts) => {
    let currentAddres = accounts[0]
    it('Linux staking should stake some tokens', async () => {})
})
