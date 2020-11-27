pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Dividends.sol";

/*
// Bonding token where part of every buy/sell has a fee going to dividend
// owners, where shares are issued to an address with each buy with the caveat
// that the share amount per buy decreases every N blocks
*/
contract DividendBondingCurve is ERC20 {
  using SafeMath for uint256;

  // fee amount for every buy/sell parts per hundred thousand e.g 
  // 1000 = 1000/100000 = 1%
  uint256 public fee;
  uint256 public feeBase = 100000;

  // current eth balance
  uint256 public poolSupply = 0;

  uint256 public dec = 10 ** 18;
  uint256 public multiple = 10 ** 10;

  // every how many blocks the share multiplier halves
  uint256 public halvingBlockInterval;

  uint256 public createdAtBlock;

  // address of contract which holds fees
  address payable dividendContractAddress;
  // contract instance
  Dividends dividendContract;

  /**
   * @dev constructor
   */
  constructor(
    uint256 _halvingBlockInterval,
    uint256 _fee,
    address payable _dividendContractAddress,
    string memory name,
    string memory symbol
  ) 
  public ERC20(name, symbol) {
    createdAtBlock = block.number;
    fee = _fee;
    halvingBlockInterval = _halvingBlockInterval;
    dividendContractAddress = _dividendContractAddress;
    dividendContract = Dividends(_dividendContractAddress);
    // issues one token to msg.sender for buy/sell math to work
    _mint(msg.sender, 10**uint256(decimals()));
  }

  /**
   * @dev
   *
   */
  function sell(address seller, uint256 amount) public {
    require(msg.sender == seller, "sender not seller");
    uint256 retAmount = calculateSellReward(amount);
    uint256 feeAmount = calculateFeeAmount(retAmount);
    _burn(seller, amount);
    // we take a fee on the returned ether and dont issue shares
    dividendContractAddress.send(feeAmount);
    poolSupply = poolSupply.sub(retAmount);
    (msg.sender).send(retAmount.sub(feeAmount));
  }

  /**
   * @dev
   *
   */
  function buy(uint256 tokenAmount) public payable {
    uint256 buyPriceEther = calculateBuyPrice(tokenAmount);
    require(msg.value >= buyPriceEther, "buy price higher than eth provided");
    uint256 feeAmount = calculateFeeAmount(buyPriceEther);
    uint256 postFeeAmount = (buyPriceEther).sub(feeAmount);
    _mint(msg.sender, tokenAmount);
    dividendContractAddress.send(feeAmount);
    poolSupply = poolSupply.add(postFeeAmount);
    (msg.sender).send(msg.value.sub(buyPriceEther));
  }

  /**
   * @dev
   * @param amount amount of tokens to sell
   * @return amount of ether returned
   */
  function calculateSellReward(uint256 amountToSell) public view returns (uint256) {
    uint256 totalTokens = totalSupply().sub(amountToSell);
    uint256 m = multiple;
    uint256 d = dec;
    // TODO check overflow
    // same as totalTokens^3
    uint256 finalPrice = poolSupply.sub(m.mul(totalTokens).mul(totalTokens).div(uint256(2).mul(d).mul(d)));
    return finalPrice; 
  }

  /**
   * @dev
   * @param amount - amount of tokens to buy
   * @return amount of ether required
   */
  function calculateBuyPrice(uint256 amountToBuy) public view returns (uint256) {
    uint256 totalTokens = amountToBuy.add(totalSupply());
    uint256 m = multiple;
    uint256 d = dec;
    uint256 finalPrice = (m.mul(totalTokens).mul(totalTokens).div(uint256(2).mul(d).mul(d))).sub(poolSupply);
    return finalPrice;
  }

  /**
   * @dev
   *
   */
  function calculateFeeAmount(uint256 amount) internal returns (uint256) {
    return (amount.mul(fee)).div(feeBase);
  }

  /**
   * @dev
   *
   */
  function calculateShareAmount(uint256 buyAmount) internal returns (uint256) {
    uint256 exp = ((block.number).sub(createdAtBlock)).div(halvingBlockInterval);
    uint256 shareAmount = buyAmount.div(2 ** exp);
    return shareAmount;
  }

}