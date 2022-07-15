pragma solidity ^0.5.8;

import "./SafeMath.sol";
import "./StakingInterface.sol";
import "./StakingStorage.sol";

contract FireMining is StakingInterface {
    using SafeMath for uint256;

    bool internal initTotalRewards = false;

    constructor (uint256 _startTime, uint256 _finishTime) public {
        require(block.timestamp <= _startTime && _finishTime > _startTime);
        startTime = _startTime;
        finishTime = _finishTime;
    }

    function claim() public returns (bool) {
        return claimInternal(msg.sender);
    }

    function rewards(address _account) public returns (uint256){
        return rewardsInternal(_account);
    }

    function staking(uint256 _amount) external {
        require(block.timestamp >= startTime && block.timestamp <= finishTime, "mining is not active");
        require(EIP20Interface(underlying).allowance(msg.sender, address(this)) >= _amount, "need approve");
        stakingInternal(msg.sender, _amount, underlying);
    }

    function redeem(uint256 _amount) external {
        redeemInternal(msg.sender, _amount, underlying);
    }

    function _totalSupply() public returns (uint256) {
        return totalSupplyInternal(address(this));
    }

    function _balanceOf(address _account) public returns (uint256) {
        return balanceOfInternal(_account);
    }

    function _freed() nonreenter public {
        require(block.timestamp > finishTime, "not in time range");
        _doTransferOut(freed, EIP20Interface(underlying).balanceOf(address(this)), underlying);
    }

    function _initTotalRewards(uint256 _totalRewards) nonreenter public {
        require(msg.sender == freed && !initTotalRewards, "not multiple times initTotalRewards");
        initTotalRewards = true;
        totalRewards = _totalRewards;
        _doTransferIn(msg.sender, _totalRewards, underlying);
    }

    function _doTransferIn(address from, uint amount, address _token) internal returns (uint) {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(_token);
        uint balanceBefore = EIP20Interface(_token).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {
                    success := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        require(success, "TransferIn::TOKEN_TRANSFER_IN_FAILED");

        uint balanceAfter = EIP20Interface(_token).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;
    }

    function _doTransferOut(address payable to, uint amount, address _token) internal {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(_token);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {
                    success := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        require(success, "TransferOut::TOKEN_TRANSFER_OUT_FAILED");
    }
}