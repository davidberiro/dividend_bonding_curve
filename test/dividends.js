const Dividends = artifacts.require("./Dividends.sol");

contract("Dividends", accounts => {
  let dividendsContract;

  before(async () => {
    dividendsContract = await Dividends.new();
  });

  it("Should initialize with correct state variable values", async () => {
    const totalShares = await dividendsContract.totalShares.call();
    const totalDividends = await dividendsContract.totalDividends.call();

    assert.equal(totalShares, 0, "total shares not zero");
    assert.equal(totalDividends, 0, "total dividends not zero");
  });
});
