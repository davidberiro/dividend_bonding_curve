const { default: getWeb3 } = require("../client/src/getWeb3");

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
    const decimals = await bondingTokenContract.decimals.call();
    const totalSupply = (await bondingTokenContract.totalSupply.call()).toString();
    const fee = await bondingTokenContract.fee.call();
    const halvingBlockInterval = await bondingTokenContract.halvingBlockInterval.call(); 
    assert.equal(decimals, 18, "total shares not zero");
    assert.equal(totalSupply, "1000000000000000000", "total dividends not zero");
    assert.equal(fee, "1000", "fee not 1000 (1%)");
    assert.equal(halvingBlockInterval, "10", "halving block interval not 10");
  });

  it("Should issue equal shares as token when halving is zero", async () => {
  });

  it("Should be able to withdraw half of shares for fees", async () => {
  });

  it("Should issue half shares as token when halving is one", async () => {
  });

  it("Should be able to withdraw all of shares for fees", async () => {
  });
});

async function incrementBlocks(numOfBlocks, accounts) {
  for (let i = 0; i < numOfBlocks; i++) {
    await web3.eth.sendTransaction({ from: accounts[5], to: accounts[6], value: 1});
  }
}