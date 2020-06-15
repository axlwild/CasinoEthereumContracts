const Ruleta = artifacts.require("Ruleta");

module.exports = function(deployer) {
    deployer.deploy(Ruleta, {gas: 5500000, value: 1000000000000000000, from: '0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2'});
};


/**
 * Deploying 'Ruleta'
   ------------------
   > transaction hash:    0x00205741f0180a10a651a2e05525e415d93b413467ee2ded283589a6b4baa3d6
   > Blocks: 1            Seconds: 16
   > contract address:    0x2ce2491193C80Ed8361b3B4a8Ff89d4E918C358E
   > block number:        8099042
   > block timestamp:     1592246081
   > account:             0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2
   > balance:             11.1037314150009
   > gas used:            4457006 (0x44022e)
   > gas price:           20 gwei
   > value sent:          1 ETH
   > total cost:          1.08914012 ETH
 */
