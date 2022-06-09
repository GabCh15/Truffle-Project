var assert = require('assert')
const Linux = artifacts.require('Linux')
const Windows = artifacts.require('Windows')

let linux
let windows

beforeEach(async () => {
    linux = await Linux.deployed()
    windows = await Windows.deployed()
})

contract('Windows', (accounts) => {
    it('Windows should mint multiple tokens', async () => {
        let currentAddres = accounts[0]
        await linux.sendTransaction({value:1000})
        await linux.approve(windows.address, 1000)
        await windows.mintMultipleTokens(2)
        assert.equal(await windows.balanceOf(currentAddres), 2, 'User has not 2 NFTs')
    })
    it()
})
