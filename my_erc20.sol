// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract my_erc20 {
    string public name = "My Token"; //名称
    string public symbol = "MTK" ; //符号
    uint8 public decimals = 18; // 小数位数
    uint256 public totalSupply; //总发行量

    address public owner; //合约拥有者

    //存储账户余额
    mapping(address => uint256) public balanceOf;

    //存储授权信息 owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    //事件定义
    //转账
    event Transfer(address indexed from, address indexed to, uint256 value);
    //授权
    event Approval(address indexed owner, address indexed spender, uint256 value);


    // 修饰器：仅所有者可调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }


    //构造函数
    constructor(uint256 initialSupply){
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //转账功能
    function transfer(address to, uint256 value) public returns (bool){
        require(balanceOf[msg.sender] >= value, "Insufficient balance.");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
      return true;
    }

    // 授权功能
    function approval(address spender, uint256 value) public returns (bool){
        require(spender != address(0), "Invaild address");

        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    //授权转账功能
    function transferFrom( address from, address to, uint256 value) public returns(bool) {
        require(from != address(0), "Insufficient balance.");
        require(to != address(0), "Insufficient balance.");
        
        require(balanceOf[from] >= value, "Insufficient balance.");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance.");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        
        allowance[from][msg.sender] -= value;
        
        emit Transfer(from, to, value);
       return  true;
    }

    // 增发代币（允许合约所有者）
    function mint(address to,uint256 amount) public onlyOwner returns ( bool){
        require(to != address(0), "Invaild address");
        uint256 mintAmount = amount *10 ** uint256(decimals) ;
        balanceOf[to] += mintAmount;
        totalSupply += mintAmount;

        emit Transfer(address(0), to, mintAmount);
        return true;
    }
}