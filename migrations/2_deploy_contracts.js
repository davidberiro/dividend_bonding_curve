var Dividends = artifacts.require("./Dividends.sol");
var DividendBondingCurve = artifacts.require("./DividendBondingCurve.sol");

module.exports = async function(deployer) {
  await deployer.deploy(Dividends);
  const dividendsContract = await Dividends.deployed();
  await deployer.deploy(
    DividendBondingCurve,
    1000, // fee
    10, // halving block interval
    dividendsContract.address,
    "Token",
    "TKN"
  );
  const curveContract = await DividendBondingCurve.deployed();
  await dividendsContract.transferOwnership(curveContract.address);
};
