pragma solidity ^0.5.8;

contract EIP20NonStandardInterface {

    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _dst, uint256 _amount) external;
    function transferFrom(address _src, address _dst, uint256 _amount) external;
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}