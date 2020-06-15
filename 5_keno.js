// TODO: seguir intentando desplegar.
const Keno = artifacts.require("Keno");

module.exports = function(deployer) {
    deployer.deploy(Keno,  {gas: 5500000, value: 1000000000000000000, from: '0xC1d89b29c3694F6c62B4a46C40DFA3E1854ffCC2'});
};


/**

 */
