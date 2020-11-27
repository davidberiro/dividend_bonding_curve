pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract Dividends is Ownable {
  using SafeMath for uint256;

  // total existing shares
  uint256 public totalShares;

  // total dividends issued to date
  uint256 public totalDividends;

  // share ownership, cannot be transferred and so if smart contracts own shares
  // they may never be claimable
  mapping (address => uint256) public shares;

  // total claimed dividends to date
  mapping (address => uint256) public totalClaimedDividends;

  constructor() public {
  }

  function issueShares(address recipient, uint256 amount) public onlyOwner {
    shares[recipient] = shares[recipient].add(amount);
    totalShares = totalShares.add(amount);
  }

  function claimDividends(address payable owner, uint256 withdrawAmount) public {
    uint256 remainingDividends = getOutstandingDividends(owner);
    require(withdrawAmount <= remainingDividends, "attempting to withdraw more than remaining amount");
    totalClaimedDividends[owner] = totalClaimedDividends[owner].add(withdrawAmount);
    owner.send(withdrawAmount);
  }
  
  function getOutstandingDividends(address owner) public returns (uint256) {
    uint256 ownerShares = shares[owner];
    uint256 totalDividends = (totalDividends.mul(ownerShares)).div(totalShares);
    uint256 totalClaimed = totalClaimedDividends[owner];
    uint256 outstanding = totalDividends.sub(totalClaimed);
    return outstanding;
  }

  /**
   * @dev fallback payable function
   */
  receive() external payable onlyOwner {
    totalDividends = totalDividends.add(msg.value);
  }
}