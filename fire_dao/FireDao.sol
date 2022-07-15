// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FireDao {
    address public owner;
    address public pending_admin;
    address public token;

    uint public constant DAO_CYCLE = 30 days;
    uint public constant FREQUENCY = 6;

    uint public constant FIRST = 1630425600;
    uint public SECOND;
    uint public THIRD;
    uint public FOURTH;
    uint public FIFTH;
    uint public SIXTH;

    mapping(address => uint256) private privateRound;
    mapping(address => uint256) public totalWithdrawnMap;

    event Mint(address _spender, uint256 _value);
    event Freed(address _address, uint256 _value);
    event Withdraw(address _to, uint256 _value, uint _time);
    event PendingAdmin(address _old, address _pending);
    event AcceptAdmin(address _pending);

    bool private reentrant = true;
    modifier nonReentrant() {
        require(reentrant, "re-entered");
        reentrant = false;
        _;
        reentrant = true;
    }

    constructor(address _tokenAddress, uint _decimals) {
        owner = msg.sender;
        token = _tokenAddress;
        _initPrivateRound(_decimals);

        SECOND = FIRST + DAO_CYCLE;
        THIRD = SECOND + DAO_CYCLE;
        FOURTH = THIRD + DAO_CYCLE;
        FIFTH = FOURTH + DAO_CYCLE;
        SIXTH = FIFTH + DAO_CYCLE;
    }

    function total() public view returns(uint256) {
        return FREQUENCY * privateRound[msg.sender];
    }

    function withdrawn() public view returns(uint256) {
        return totalWithdrawnMap[msg.sender];
    }

    function vestedAmount() public view returns (uint256) {
        return privateRound[msg.sender];
    }

    function remainingAmountToBeVested() public view returns(uint256) {
        return FREQUENCY * privateRound[msg.sender] - totalWithdrawnMap[msg.sender];
    }

    function currentMaximum(address _address) public view returns(uint256) {
        uint256 _currentCycle = currentCycle();
        if(uint256(0) == _currentCycle) {
            return uint256(0);
        }
        return _currentCycle * privateRound[_address] - totalWithdrawnMap[_address];
    }

    function withdraw(address payable _address, uint256 _value, uint _time) public payable nonReentrant {
        require(block.timestamp >= FIRST, "Withdraw Unopened");
        require(msg.sender == _address && _value > uint256(0));
        require(_value <= currentMaximum(_address), "Withdraw value: Must be less than the largest");
        require(EIP20Interface(token).balanceOf(address(this)) >= _value, "Withdraw insufficient balance");

        _doTransferOutToken(_address, _value);
        totalWithdrawnMap[_address] = totalWithdrawnMap[_address] + _value;

        emit Withdraw(_address, _value, _time);
    }

    function currentCycle() internal view returns(uint) {
        uint _time = block.timestamp;
        if(_time < FIRST) {
            return uint(0);
        }else if(_time >= FIRST && _time < SECOND) {
            return uint(1);
        }else if(_time >= SECOND && _time < THIRD) {
            return uint(2);
        }else if(_time >= THIRD && _time < FOURTH) {
            return uint(3);
        }else if(_time >= FOURTH && _time < FIFTH) {
            return uint(4);
        }else if(_time >= FIFTH && _time < SIXTH) {
            return uint(5);
        }else {
            return uint(6);
        }
    }

    function _mint(uint256 _value) public {
        require(_value > uint256(0));
        _doTransferInToken(msg.sender, _value);
        emit Mint(msg.sender, _value);
    }

    function _freed(address payable _address, uint256 _value) public nonReentrant {
        require(msg.sender == owner, "freed: only owner");
        require(_value > uint(0), "freed: value must be greater than zero");
        require(EIP20Interface(token).balanceOf(address(this)) >= _value, "freed: insufficient balance");
        _doTransferOutToken(_address, _value);
        emit Freed(_address, _value);
    }

    function _doTransferInToken(address _from, uint256 _amount) internal returns (uint) {
        EIP20NonStandardInterface _token = EIP20NonStandardInterface(token);
        uint256 balanceBefore = EIP20Interface(token).balanceOf(address(this));
        _token.transferFrom(_from, address(this), _amount);
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
        require(success, "doTransferIn failure");

        uint256 balanceAfter = EIP20Interface(token).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "doTransferIn::balanceAfter >= balanceBefore failure");
        return balanceAfter - balanceBefore;
    }

    function _doTransferOutToken(address payable _to, uint256 _amount) internal {
        EIP20NonStandardInterface _token = EIP20NonStandardInterface(token);
        _token.transfer(_to, _amount);
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
        require(success, "dotransferOut failure");
    }
    
    function _setPendingAdmin(address _pending) public nonReentrant {
        require(msg.sender == owner, "_pendingAdmin only owner");
        pending_admin = _pending;
        emit PendingAdmin(owner, _pending);
    }

    function _acceptPendingAdmin() public nonReentrant {
        require(msg.sender == pending_admin, "_accept only pending_admin");
        owner = pending_admin;
        pending_admin = address(0);
        emit AcceptAdmin(pending_admin);
    }

    function _initPrivateRound(uint decimals) internal {
        privateRound[address(0x8b90b067d02132fC7c5cDf64b8cac04D55aBC2B2)] = 65_000 * 10**decimals;
        privateRound[address(0xAEFf65e9Fd71ACd84443B2BDfA71a4444B716cDf)] = 99_450 * 10**decimals;
        privateRound[address(0xaa06ba6a7dcee3e81F5CAbbAb7Fcc1b9d9cfd4d8)] = 32_500 * 10**decimals;
        privateRound[address(0x0Ed67dAaacf97acF041cc65f04A632a8811347fF)] = 6_500 * 10**decimals;
        privateRound[address(0xf84d67b40f41429d519c155D9A93E3C7767F8508)] = 26_650 * 10**decimals;
        privateRound[address(0xBdEDd3A331a58EfAb74c70a7A1E2305eFefce8c1)] = 180_557 * 10**(decimals-1);
        privateRound[address(0xC6dDF90790b433743bd050c1D1d45f673A3413F4)] = 29_250 * 10**decimals;
        privateRound[address(0xff4d2D37a08f1B0d40dda7eAd1D88Aa5ceEF7C66)] = 13_000 * 10**decimals;
        privateRound[address(0x0051437667689B36f9cFec31E4F007f1497c0F98)] = 39_000 * 10**decimals;
        privateRound[address(0xa777D9a1BedFe3E4Df943BCFdD5B13Ace8B1f2f7)] = 13_000 * 10**decimals;
        privateRound[address(0xb584200eC694781f14c7a283FD1Dec8C27b4d09D)] = 3_900 * 10**decimals;
        privateRound[address(0xDe8bb8B54E69e15217B351f1500730b85c9F8711)] = 32_500 * 10**decimals;
        privateRound[address(0xf503feb4f6570E0A44C5231dF53dAE3fb5d7d628)] = 65_000 * 10**decimals;
        privateRound[address(0x52723aD7dA5a10B93F91845faC5597F2BC93D510)] = (32_500 + 16_250) * 10**decimals;
        privateRound[address(0x8888888888E9997E64793849389a8Faf5E8e547C)] = 13_000 * 10**decimals;
        privateRound[address(0x9e12da5Ca525Ad3EF2a35Bf8286369b3eeB0A0d2)] = 13_000 * 10**decimals;
        privateRound[address(0x4D5f297073601992e37113aeb1578Cad58fE6604)] = 617_435 * 10**(decimals-2);
        privateRound[address(0x17b112745FfA99FBd63e5F50E4d9ae5A55d083bA)] = 6_500 * 10**decimals;
        privateRound[address(0xC022458FcE8965c59fe2a8F914A9b7aE45528517)] = 32_500 * 10**decimals;
        privateRound[address(0x2ca3F2385e7B6cCC8eeFa007cA62bcf85DF8e89E)] = 6_500 * 10**decimals;
        privateRound[address(0x30550067157683E94f0294135F12a57A1098dcdf)] = 79_950 * 10**decimals;
        privateRound[address(0x7bfFCd7D2C17D534EDf4d1535c8c44324eb13A36)] = 6_500 * 10**decimals;
        privateRound[address(0xeccE08c2636820a81FC0c805dBDC7D846636bbc4)] = 6_500 * 10**decimals;
        privateRound[address(0x8465646bAe2fEbC4db739bA3829c7c90E6999999)] = 27_300 * 10**decimals;
        privateRound[address(0x3d2681016E94D72791f04A4C5Df937DF13557385)] = 52_000 * 10**decimals;
        privateRound[address(0x56Dd7fC6af7e11f7dA320Da513C6C37fD201D322)] = 6_500 * 10**decimals;
    }
}

interface EIP20Interface {
    function balanceOf(address _address) external view returns (uint256 _balance);
    function transfer(address _address, uint256 _amount) external returns (bool _flag);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

interface EIP20NonStandardInterface {
    function transfer(address _dst, uint256 _amount) external;
    function transferFrom(address _src, address _dst, uint256 _amount) external;
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}