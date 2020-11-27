var Dividends = artifacts.require("./Dividends.sol");
var DividendBondingCurve = artifacts.require("./DividendBondingCurve.sol");

module.exports = async function(deployer) {
  const dividendsContract = await deployer.deploy(Dividends);
  const curveContract = await deployer.deploy(DividendBondingCurve);
  // add this after making front end work
  //await dividendsContract.transferOwnership(curveContract.address);
};
