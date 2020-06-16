const KenoSP = artifacts.require("KenoSP");

module.exports = function(deployer) {
    deployer.deploy(KenoSP, {gas: 5500000, value: 1000000000000000000, from: '0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2'});
};


/**
10_ruleta_v2.js
===============
 Deploying 'KenoSP'
   ------------------
   > transaction hash:    0xa02a8090f38b011593e3b0346a06a375f492b6b3c06df7b27e19548cbd906cd2
   > Blocks: 2            Seconds: 152
   > contract address:    0x97e90813EEA78654B59b3B438131EF2684cf6962
   > block number:        8106177
   > block timestamp:     1592328185
   > account:             0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2
   > balance:             34.118798220449409375
   > gas used:            2890754 (0x2c1c02)
   > gas price:           20 gwei
   > value sent:          1 ETH
   > total cost:          1.05781508 ETH
 */
