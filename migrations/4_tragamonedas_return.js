const Tragamonedas3 = artifacts.require("Tragamonedas3");

module.exports = function(deployer) {
    deployer.deploy(Tragamonedas3,  {gas: 9000000, value: 500000000000000000});
};


/**
   Deploying 'Tragamonedas3'
   -------------------------
   > transaction hash:    0xd2dfe63677a9758ec20cef6427cd241ac729145f117fddb73820499a5d536689
   > Blocks: 4            Seconds: 74
   > contract address:    0xC569b354C8cA672699e50Aa354EDcbecDa47d442
   > block number:        8095086
   > block timestamp:     1592191974
   > account:             0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2
   > balance:             8.5623871290009
   > gas used:            2465748 (0x259fd4)
   > gas price:           20 gwei
   > value sent:          0.5 ETH
   > total cost:          0.54931496 ETH
 */
