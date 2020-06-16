const Tragamonedas = artifacts.require("Tragamonedas");

module.exports = function(deployer) {
    deployer.deploy(Tragamonedas,  {value: 500000000000000000});
};


/**
   7_tragamonedas_ori.js
=====================

   Replacing 'Tragamonedas'
   ------------------------
   > transaction hash:    0x1a5ae7e838943e53097812e75b189aca11c42cc0d6faf38ee6e36f1bc44f367e
   > Blocks: 22           Seconds: 192
   > contract address:    0x240859f0987A0aa503B1149D96B0d4e532B12E3C
   > block number:        8102935
   > block timestamp:     1592269922
   > account:             0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2
   > balance:             7.990159116851009375
   > gas used:            3853698 (0x3acd82)
   > gas price:           20 gwei
   > value sent:          0.5 ETH
   > total cost:          0.57707396 ETH

   Pausing for 2 confirmations...
   ------------------------------
   > confirmation number: 1 (block: 8102935)
   > confirmation number: 3 (block: 8102937)

   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.57707396 ETH


Summary
=======
> Total deployments:   1
> Final cost:          0.57707396 ETH
 */
