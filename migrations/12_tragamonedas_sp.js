const TragamonedasSP = artifacts.require("TragamonedasSP");

module.exports = function(deployer) {
    deployer.deploy(TragamonedasSP,  {value: 1000000000000000000});
};


/**

 */
