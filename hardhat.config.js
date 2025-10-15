require('@nomicfoundation/hardhat-toolbox');
require('@nomicfoundation/hardhat-verify');
require('@nomicfoundation/hardhat-ethers');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    base: {
      url: 'https://mainnet.base.org',
      chainId: 8453,
      accounts: ['YOUR_PRIVATE_KEY'],
    },
  },
  etherscan: {
    apiKey: {
      base: 'YOUR_BLOCKSCOUT_API_KEY',
    },

    customChains: [
      {
        network: 'base',
        chainId: 8453,
        urls: {
          apiURL: 'https://base.blockscout.com/api',
          browserURL: 'https://base.blockscout.com',
        },
      },
    ],
  },

  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: {
        enabled: false, // or true — match what Remix had
        runs: 200,
      },
    },
  },
};
