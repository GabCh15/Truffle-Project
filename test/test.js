const { assert, expect } = require('chai')
const {
    time,
    expectRevert,
    expectEvent,
    BN,
} = require('@openzeppelin/test-helpers')
const Linux = artifacts.require('Linux')
const LinuxStaking = artifacts.require('LinuxStaking')
const Windows = artifacts.require('Windows')
const KaliLinux = artifacts.require('KaliLinux')
const WindowsXP = artifacts.require('WindowsXP')

let linux, windows, linuxStaking, windowsXP, kaliLinux

before(async () => {
    linux = await Linux.new()
    windows = await Windows.new(linux.address)
    linuxStaking = await LinuxStaking.new(linux.address)
    //Approve and call contracts
    kaliLinux = await KaliLinux.new()
    windowsXP = await WindowsXP.new(kaliLinux.address)
})

contract('Windows', ([owner, user]) => {
    let sender = { from: user }

    before(async () => {
        await linux.firstMint({ value: 1000, from: user })
        await linux.approve(windows.address, 1000, sender)
    })

    it('Windows should mint multiple tokens', async () => {
        await windows.mintMultipleTokens(2, sender)
        assert.equal(await linux.balanceOf(owner), 19)
        assert.equal(await windows.balanceOf(user), 2, 'User has not 2 NFTs')
    })

    it('Windows should not mint any token', async () => {
        await windows.setIsMintEnabled(false)
        await expectRevert(
            windows.mintToken(),
            'Mint is no enabled at this moment!'
        )
    })
})

contract('Linux', ([owner, user]) => {
    before(async () => {
        await linux.firstMint({ value: 1000, from: user })
    })
    it('Should not mint tokens twice', async () => {
        await expectRevert(
            linux.firstMint({ value: 1000, from: user }),
            'Sender is not allowed to mint!'
        )
    })
})

contract('LinuxStaking', ([owner, user]) => {
    let sender = { from: user }
    before(async () => {
        await linux.setStakingAddress(linuxStaking.address)
        await linux.firstMint({ value: 1000, from: user })
        await linux.approve(linuxStaking.address, 1000, sender)
    })

    it('Linux staking should stake some tokens', async () => {
        await linuxStaking.deposit(50, sender)
        await linuxStaking.deposit(50, sender)
        assert.equal(
            await linux.balanceOf(linuxStaking.address),
            100,
            "Tokens weren't staked"
        )
    })
    it('Linux staking should retrieve the tokens', async () => {
        await linuxStaking.deposit(50, sender)
        await linuxStaking.retrieve(sender)
        await linuxStaking.deposit(100, sender)
        await linuxStaking.retrieve(sender)
        assert.equal(await linux.balanceOf(linuxStaking.address), 0)
    })
    it('Linux staking should mint the rewards and retrieve staked amount back', async () => {
        let currentBalance = await linux.balanceOf(user)
        await linuxStaking.deposit(100, sender)
        await new Promise((resolve) => setTimeout(resolve, 1000))
        await linuxStaking.exit(sender)
        expect(parseInt(await linux.balanceOf(user))).to.greaterThan(parseInt(currentBalance))
    })
})

contract('Kali Linux', (accounts) => {
    let currentAddress = accounts[0]
    it('Approve and call should work for Kali and WindowsXP', async () => {
        await kaliLinux.firstMint({ value: 1000 })
        let dataTocall = web3.eth.abi.encodeFunctionCall(
            {
                inputs: [
                    { internalType: 'address', name: 'buyer', type: 'address' },
                ],
                name: 'mintToken',
                type: 'function',
            },
            [currentAddress]
        )
        await kaliLinux.approveAndCall(windowsXP.address, 10, dataTocall)
        assert.equal(await windowsXP.balanceOf(currentAddress), 1)
    })
})

