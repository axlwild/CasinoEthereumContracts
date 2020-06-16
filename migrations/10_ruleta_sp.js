const Ruleta2 = artifacts.require("Ruleta2");

module.exports = function(deployer) {
    deployer.deploy(Ruleta2, {gas: 5500000, value: 1000000000000000000, from: '0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2'});
};


/**
10_ruleta_v2.js
===============

   Deploying 'Ruleta2'
   -------------------
   > transaction hash:    0x8a28095b3426a9eca3b7d9f7b20fd206434728f253ded0bd8d415e4f7abb6538
   > Blocks: 1            Seconds: 20
   > contract address:    0xc67e981E0efea062b1f1f45958ABa8af231e5C4F
   > block number:        8106149
   > block timestamp:     1592327431
   > account:             0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2
   > balance:             35.177160120449409375
   > gas used:            4482646 (0x446656)
   > gas price:           20 gwei
   > value sent:          1 ETH
   > total cost:          1.08965292 ETH
   JSON.stringify(Ruleta2.abi)
 */
