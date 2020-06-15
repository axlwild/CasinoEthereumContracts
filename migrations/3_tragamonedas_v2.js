const Tragamonedas_2 = artifacts.require("Tragamonedas_2");

module.exports = function(deployer) {
    deployer.deploy(Tragamonedas_2,  {gas: 5500000, value: 500000000000000000});
};


/**
    Deploying 'Tragamonedas_2'
   --------------------------
   > transaction hash:    0x8424e5d05d1a229272bd6c74d6486617c6abe95c655ee8f29869073015df280e
   > Blocks: 1            Seconds: 24
   > contract address:    0x2Cf911305d29ca55C1E0826f097a75037d5c8A2A
   > block number:        8094467
   > block timestamp:     1592183554
   > account:             0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2
   > balance:             9.1339281158009
   > gas used:            3684426 (0x38384a)
   > gas price:           20 gwei
   > value sent:          0.5 ETH
   > total cost:          0.57368852 ETH
 */
