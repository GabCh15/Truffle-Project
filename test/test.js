var assert = require('assert')
const { ethers } = require('ethers')
const Linux = artifacts.require('Linux')
const LinuxStaking = artifacts.require('LinuxStaking')
const Windows = artifacts.require('Windows')
const KaliLinux = artifacts.require('KaliLinux')
const WindowsXP = artifacts.require('WindowsXP')

let linux, windows, linuxStaking, windowsXP, kaliLinux

beforeEach(async () => {
    linux = await Linux.new()
    windows = await Windows.new(linux.address)
    linuxStaking = await LinuxStaking.new(linux.address)
    //Approve and call contracts
    kaliLinux = await KaliLinux.new()
    windowsXP = await WindowsXP.new(kaliLinux.address)
})

function asExecuteArg(functionName, argTypes, ...args) {
    let signature = `function ${functionName}(${argTypes})`
    let ABI = [signature]
    let interface = new ethers.utils.Interface(ABI)
    let output = interface.encodeFunctionData(functionName, args)
    return output
}

contract('Windows', (accounts) => {
    let currentAddress = accounts[0]
    it('Windows should mint multiple tokens', async () => {
        await linux.firstMint({ value: 1000 })
        await linux.approve(windows.address, 1000)
        await windows.mintMultipleTokens(2)
        assert.equal(
            await windows.balanceOf(currentAddress),
            2,
            'User has not 2 NFTs'
        )
    })
    /*     it('Windows should not mint any token', async () => {
        await linux.firstMint({ value: 1000 })
        await linux.approve(windows.address, 1000)
        await windows.setIsMintEnabled(false)
        try {
            console.log(await windows.mintToken())
        } catch (e) {}

        assert.equal(
            await windows.balanceOf(currentAddress),
            0,
            'User minted succesfully'
        )
    }) */
})

contract('Linux', (accounts) => {
    let currentAddress = accounts[0]
    /*     it('Should not mint tokens twice', async () => {
        try {
            await linux.firstMint({ value: 1000 })
            await linux.firstMint({ value: 1000 })
        } catch (e) {
        }
        assert.equal(
            await linux.balanceOf(currentAddress),
            1000,
            'User minted twice'
        )
    }) */
})

contract('LinuxStaking', (accounts) => {
    let currentAddress = accounts[0]
    /*it('Linux staking should stake some tokens', async () => {
        await linux.setStakingAddress(linuxStaking.address)
        await linux.firstMint({ value: 1000 })
        await linux.approve(linuxStaking.address, 1000)
        await linuxStaking.deposit(100)
        await linuxStaking.deposit(100)
        assert.equal(
            await linux.balanceOf(linuxStaking.address),
            200,
            "Tokens weren't staked"
        )
    })*/
    /*     it('Linux staking should retrieve the tokens', async () => {
        await linux.setStakingAddress(linuxStaking.address)
        await linux.firstMint({ value: 1000 })
        await linux.approve(linuxStaking.address, 10000)
        await linuxStaking.deposit(100)
        await linuxStaking.retrieve()
        await linuxStaking.deposit(200)
        await linuxStaking.retrieve()
        assert.equal(await linux.balanceOf(linuxStaking.address), 0)
    })
    it('Linux staking should mint the rewards', async () => {
        await linux.firstMint({ value: 100 })
        await linux.approve(linuxStaking.address, 10000)
        await linuxStaking.deposit(100)
        await new Promise((resolve) => setTimeout(resolve, 1000))
        await linuxStaking.getReward()
        assert.equal(
            await linux.balanceOf(currentAddress),
            100,
            "Address didn't get the reward"
        )
    })
    it('Linux staking should mint the rewards and retrieve staked amount back', async () => {
        await linux.firstMint({ value: 100 })
        await linux.approve(linuxStaking.address, 10000)
        await linuxStaking.deposit(100)
        await new Promise((resolve) => setTimeout(resolve, 1000))
        await linuxStaking.getReward()
        assert.equal(
            await linux.balanceOf(currentAddress),
            200,
            "Address didn't get the reward and retrieve"
        )
    }) */
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
