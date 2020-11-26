pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Dividends is Ownable {
  using SafeMath for uint256;

  // base token
  ERC20 dividendToken;

  // total existing shares
  uint256 totalShares;

  // total dividends issued to date
  uint256 totalTokenDividends;

  // share ownership, cannot be transferred and so if smart contracts own shares
  // they may never be claimable
  mapping (address => uint256) shares;

  // total claimed dividends to date
  mapping (address => uint256) totalClaimedDividends;

  constructor(address _dividendToken) public {
    dividendToken = ERC20(_dividendToken);
  }

  function claimDividends(address owner, uint256 withdrawAmount) public {
    uint256 remainingDividends = getOutstandingDividends(owner);
    require(withdrawAmount <= remainingDividends, "attempting to withdraw more than remaining amount");
    totalClaimedDividends[owner] += withdrawAmount;
    dividendToken.transfer(owner, withdrawAmount);
  }
  
  function getOutstandingDividends(address owner) internal returns (uint256) {
    uint256 ownerShares = shares[owner];
    uint256 totalDividends = (totalTokenDividends.mul(ownerShares)).div(totalShares);
    uint256 totalClaimed = totalClaimedDividends[owner];
    uint256 outstanding = totalDividends.sub(totalClaimed);
    return outstanding;
  }
}