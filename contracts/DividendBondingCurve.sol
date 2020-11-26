pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/*
// Bonding token where part of every buy/sell has a fee going to dividend
// owners, where shares are issued to an address with each buy with the caveat
// that the share amount per buy decreases every N blocks
*/
contract DividendBondingCurve is ERC20 {
  using SafeMath for uint256;

  // fee amount for every buy/sell parts per hundred thousand e.g 
  // 1000 = 1000/100000 = 1%
  uint256 fee;
  uint256 feeBase = 100000;

  // every how many blocks the share multiplier halves
  uint256 halvingBlockInterval;

  uint256 createdAtBlock;

  // address of contract which holds fees
  address payable dividendContract;

  /**
   * @dev
   *
   */
  constructor(
    uint256 _halvingBlockInterval,
    string memory name,
    string memory symbol
  ) 
  public ERC20(name, symbol) {
    createdAtBlock = block.number;
    halvingBlockInterval = _halvingBlockInterval;
  }

  /**
   * @dev
   *
   */
  function sell(address seller, uint256 amount) public {
    require(msg.sender == seller, "sender not seller");
    uint256 retAmount = calculateSellAmount(amount);
    uint256 feeAmount = calculateFeeAmount(retAmount);
    _burn(seller, amount);
    // we take a fee on the returned ether and dont issue shares
    dividendContract.send(feeAmount);
  }

  /**
   * @dev
   *
   */
  function buy() public payable {
    uint256 feeAmount = calculateFeeAmount(msg.value);
    uint256 postFeeAmount = (msg.value).sub(feeAmount);
    uint256 buyAmount = calculateBuyAmount(postFeeAmount);
    _mint(msg.sender, buyAmount);
    dividendContract.send(feeAmount);
  }

  /**
   * @dev
   *
   */
  function calculateSellAmount(uint256 amount) internal pure returns (uint256) {
    // implement curve sell
    return amount;
  }

  /**
   * @dev
   *
   */
  function calculateBuyAmount(uint256 amount) internal pure returns (uint256) {
    // implement curve buy
    return amount;
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