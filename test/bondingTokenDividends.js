const Dividends = artifacts.require("./Dividends.sol");
const DividendBondingCurve = artifacts.require("./DividendBondingCurve.sol");

contract("Bonding token with dividends", accounts => {
  let dividendsContract;
  let bondingTokenContract;

  before(async () => {
    dividendsContract = await Dividends.deployed();
    bondingTokenContract = await DividendBondingCurve.deployed();
  });

  it("Should initialize dividends contract with correct state variable values", async () => {
    const totalShares = await dividendsContract.totalShares.call();
    const totalDividends = await dividendsContract.totalDividends.call();

    assert.equal(totalShares, 0, "total shares not zero");
    assert.equal(totalDividends, 0, "total dividends not zero");
  });

  it("Should initialize bonding token with correct state variable values", async () => {
    const totalShares = await dividendsContract.totalShares.call();
    const totalDividends = await dividendsContract.totalDividends.call();

    assert.equal(totalShares, 0, "total shares not zero");
    assert.equal(totalDividends, 0, "total dividends not zero");
  });
});
