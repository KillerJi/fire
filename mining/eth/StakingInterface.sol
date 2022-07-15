pragma solidity ^0.5.8;

import "./StakingStorage.sol";
import "./EIP20Interface.sol";
import "./EIP20NonStandardInterface.sol";

contract StakingInterface is StakingStorage {
    bool internal rernter = false;

    function _doTransferIn(address _from, uint _amount, address _token) internal returns (uint);
    function _doTransferOut(address payable _to, uint _amount, address _token) internal;

    event Staking(address indexed _account, uint256 _amount);
    event Redeem(address indexed _account, uint256 _amount);
    event Claim(address indexed _account, uint256 _amount);
    event DelegateStakingChanged(address indexed delegate, uint256 oldStaking, uint256 newStaking);

    uint256 internal xxx = uint256(1000000000);

    modifier nonreenter() {
        require(!rernter, "doTransferIn rernter");
        rernter = true;
        _;
        rernter = false;
    }

    function claimInternal(address payable _account) nonreenter internal returns (bool) {
        uint256 _claim = rewardsInternal(_account);
        require(_claim > 0, "account reward is zero");

        _doTransferOut(_account, _claim, underlying);
        accountPaid[_account] += _claim;

        emit Claim(_account, _claim);
        return true;
    }

    function rewardsInternal(address _account) internal view returns (uint256) {
        return xxx;
    }

    function stakingInternal(address _account, uint256 _amount, address _token) nonreenter internal {
        require(EIP20Interface(_token).balanceOf(_account) >= _amount, "account FIRE token insufficient coins");

        _doTransferIn(_account, _amount, _token);
        emit Staking(_account, _amount);

        _moveStakingDelegates(_account, address(0), _amount);
        _moveStakingDelegates(address(this), address(0), _amount);
    }

    function redeemInternal(address payable _account, uint256 _amount, address _token) nonreenter internal {
        require(rewardsInternal(_account) >= _amount, "insufficient coins");

        _doTransferOut(_account, _amount, _token);
        emit Redeem(_account, _amount);

        _moveStakingDelegates(msg.sender, address(0), _amount);
        _moveStakingDelegates(address(this), address(0), _amount);
    }

    function _moveStakingDelegates(address src, address dst, uint amount) internal {
        if (src != dst && amount > 0) {
            if (src != address(0)) {
                uint32 srcRepNum = numStakingCheckpoints[src];
                uint srcRepOld = srcRepNum > 0 ? stakingCheckpoints[src][srcRepNum - 1].balance : 0;
                uint srcRepNew = require_sub(srcRepOld, amount, "balance amount underflows");
                _writeStakingCheckpoint(src, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dst != address(0)) {
                uint32 dstRepNum = numStakingCheckpoints[dst];
                uint dstRepOld = dstRepNum > 0 ? stakingCheckpoints[dst][dstRepNum - 1].balance : 0;
                uint dstRepNew = require_add(dstRepOld, amount, "balance amount overflows");
                _writeStakingCheckpoint(dst, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }
    
    function _writeStakingCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldStaking, uint256 newStaking) internal {
        uint32 blockNumber = require_safe32(block.number, "_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && stakingCheckpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            stakingCheckpoints[delegatee][nCheckpoints - 1].balance = newStaking;
        } else {
            stakingCheckpoints[delegatee][nCheckpoints] = StakingCheckPoint(blockNumber, newStaking);
            numStakingCheckpoints[delegatee] = nCheckpoints + 1;
        }
        emit DelegateStakingChanged(delegatee, oldStaking, newStaking);
    }

    function totalSupplyInternal(address _contract) internal view returns (uint256) {
        return stakingCheckpoints[_contract][numStakingCheckpoints[_contract]].balance;
    }

    function balanceOfInternal(address _account) internal view returns (uint256) {
        return stakingCheckpoints[_account][numStakingCheckpoints[_account]].balance;
    }

    function require_safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function require_add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function require_sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }
}