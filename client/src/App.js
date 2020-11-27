import React, { Component } from "react";
import DividendsContract from "./contracts/Dividends.json";
import DividendBondingCurveContract from "./contracts/DividendBondingCurve.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = {
    userAddress: null,
    userEthBalance: 0,
    userShares: 0,
    totalShares: 0,
    userBalance: 0,
    totalSupply: 0,
    userTotalDividends: 0,
    userClaimedDividends: 0,
    userRemainingDividends: 0,
    halvingBlockInterval: 0,
    createdAtBlock: 0,
    web3: null,
    dividendsContractInstance: null,
    bondingCurveContractInstance: null
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetworkDividends = DividendsContract.networks[networkId];
      const deployedNetworkCurve = DividendBondingCurveContract.networks[networkId];
      const dividendsContractInstance = new web3.eth.Contract(
        DividendsContract.abi,
        deployedNetworkDividends && deployedNetworkDividends.address,
      );
      const bondingCurveContractInstance = new web3.eth.Contract(
        DividendBondingCurveContract.abi,
        deployedNetworkCurve && deployedNetworkCurve.address,
      );

      const newState = {
        web3,
        userAddress: accounts[0],
        dividendsContractInstance,
        bondingCurveContractInstance,
      };
      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState(newState, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const {
      userAddress,
      dividendsContractInstance,
      bondingCurveContractInstance,
      web3
    } = this.state;

    // one of these should work..
    const userEthBalance = (await web3.eth.getBalance(userAddress));
    const currentBlock = (await web3.eth.getBlock("latest")).number;
    //const userEthBalance = await web3.eth.balanceOf(userAddress).toString();

    const userShares = await dividendsContractInstance.methods.shares(userAddress).call();
    const totalShares = await dividendsContractInstance.methods.totalShares().call();
    const totalDividends = await dividendsContractInstance.methods.totalDividends().call();
    const userClaimedDividends = await dividendsContractInstance.methods.totalClaimedDividends(userAddress).call();
    // BN??
    const userTotalDividends = ((userShares/totalShares) * totalDividends) || 0;
    const userRemainingDividends = (userTotalDividends - userClaimedDividends) || 0;

    const userBalance = await bondingCurveContractInstance.methods.balanceOf(userAddress).call();
    const totalSupply = await bondingCurveContractInstance.methods.totalSupply().call();
    const halvingBlockInterval = await bondingCurveContractInstance.methods.halvingBlockInterval().call();
    const createdAtBlock = await bondingCurveContractInstance.methods.createdAtBlock().call();

    // Update state with the result.
    this.setState({
      userEthBalance,
      userShares,
      totalShares,
      userBalance,
      totalSupply,
      totalDividends,
      userTotalDividends,
      userClaimedDividends,
      userRemainingDividends,
      halvingBlockInterval,
      createdAtBlock,
      currentBlock
    });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Good to Go!</h1>
        <p>The bonding token and dividends contract are deployed</p>
        <h2>Current Stats -</h2>
        <p>
          If your contracts compiled and migrated successfully, below will show
          a stored value of 5 (by default).
        </p>
        <div>User address: {this.state.userAddress}</div>
        <div>Current Block (reload to refresh): {this.state.currentBlock}</div>
        <div>User eth balance: {this.state.userEthBalance}</div>
        <div>User token balance: {this.state.userBalance}, token total supply: {this.state.totalSupply}</div>
        <div>User share balance: {this.state.userShares}, total share supply: {this.state.totalShares}</div>
        <div>User remaining dividends: {this.state.userRemainingDividends}, user total dividends: {this.state.userTotalDividends}, total dividends: {this.state.totalDividends}</div>
        <div>current halving factor: {Math.floor((this.state.currentBlock - this.state.createdAtBlock)/this.state.halvingBlockInterval)}</div>
        <div>Next share halving in: {this.state.halvingBlockInterval - ((this.state.currentBlock - this.state.createdAtBlock)%this.state.halvingBlockInterval)} blocks</div>
      </div>
    );
  }
}

export default App;
