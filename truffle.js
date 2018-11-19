// const { readFileSync } = require('fs')
// const path = require('path')
// const { join } = require('path')
// const LoomTruffleProvider = require('loom-truffle-provider')
// // const HDWalletProvider = require('truffle-hdwallet-provider')

// const chainId    = 'default'
// const writeUrl   = 'http://127.0.0.1:46658/rpc'
// const readUrl    = 'http://127.0.0.1:46658/query'
// const privateKey = readFileSync('./private_key', 'utf-8')

// const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)

module.exports = {
  networks: {
    // loom_dapp_chain: {
    //   provider: loomTruffleProvider,
    //   network_id: '*'
    // },
    // extdev: {
    //   provider: function() {
    //     const privateKey = readFileSync(path.join(__dirname, 'private_key'), 'utf-8')
    //     const chainId = 'extdev-plasma-us1'
    //     const writeUrl = 'http://extdev-plasma-us1.dappchains.com:80/rpc'
    //     const readUrl = 'http://extdev-plasma-us1.dappchains.com:80/query'
    //     return new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)
    //   },
    //   network_id: 'extdev-plasma-us1'
    // },
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // Match any network id
      gas: 11093617
    }
  }
}