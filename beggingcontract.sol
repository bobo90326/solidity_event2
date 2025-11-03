// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeggingContract {
    // 合约所有者
    address public owner;
    
    // 记录每个捐赠者的捐赠金额
    mapping(address => uint256) public donations;
    
    // 所有捐赠者地址列表
    address[] public donators;

    // 新增：用于跟踪排行榜的结构
    struct Donor {
        address addr;
        uint256 amount;
    }

    // 使用数组维护排行榜（按捐赠金额降序）
    Donor[] private topDonors;

    // 最大排行榜长度（可根据需求调整）
    uint256 private constant MAX_RANKING_SIZE = 100;

     // 时间限制相关变量
    // uint256 public startTime;  // 捐赠开始时间（Unix时间戳）
    uint256 public endTime;    // 捐赠结束时间（Unix时间戳）
    
    // 事件：记录捐赠
    event Donation(address indexed donor, uint256 amount);
    
    // 事件：记录提取资金
    event Withdrawal(address indexed owner, uint256 amount);
    
    // 修饰器：仅所有者可调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw");
        _;
    }

    modifier notExpired() {
        require(block.timestamp <= endTime, "Campaign expired");
        _;
    }
    
    // 构造函数
    constructor(uint256 _endTime) {
        owner = msg.sender;
        endTime = _endTime;
    }
    
    // 捐赠函数 - 允许用户向合约发送以太币
    function donate() public payable notExpired{
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        // 如果是首次捐赠，添加到捐赠者列表
        if (donations[msg.sender] == 0) {
            donators.push(msg.sender);
        }
        
        // 更新捐赠金额
        donations[msg.sender] += msg.value;
        
        //更新排行榜
        _updateRanking(msg.sender,donations[msg.sender]);
        // 记录捐赠事件
        emit Donation(msg.sender, msg.value);
    }
    
    // 提取资金函数 - 仅所有者可调用
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available to withdraw");
        
        // 转账给所有者
        payable(owner).transfer(balance);
        
        // 记录提取事件
        emit Withdrawal(owner, balance);
    }
    
    // 获取特定地址的捐赠金额
    function getDonation(address donor) public view returns (uint256) {
        return donations[donor];
    }
    
    // 获取合约当前余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // 获取总捐赠者数
    function getDonatorCount() public view returns (uint256) {
        return donators.length;
    }
    
    // 获取所有捐赠者信息
    function getAllDonators() public view returns (address[] memory) {
        return donators;
    }

    //显示捐赠金额最多的前N个地址
    // 内部函数：更新排行榜
    function _updateRanking(address donor, uint256 amount) internal {
        // 如果已经在排行榜中，先移除
        for (uint256 i = 0; i < topDonors.length; i++) {
            if (topDonors[i].addr == donor) {
                topDonors[i] = topDonors[topDonors.length - 1];
                topDonors.pop();
                break;
            }
        }

        // 添加新记录
        topDonors.push(Donor(donor, amount));

        // 按金额降序排序（简单的冒泡排序，实际应用中可能需要优化）
        for (uint256 i = 0; i < topDonors.length - 1; i++) {
            for (uint256 j = 0; j < topDonors.length - i - 1; j++) {
                if (topDonors[j].amount < topDonors[j + 1].amount) {
                    Donor memory temp = topDonors[j];
                    topDonors[j] = topDonors[j + 1];
                    topDonors[j + 1] = temp;
                }
            }
        }

        // 限制排行榜大小
        if (topDonors.length > MAX_RANKING_SIZE) {
            topDonors.pop();
        }
    }

    // 获取前N个捐赠最多的地址
    function getTopDonors(uint256 n) external view returns (Donor[] memory) {
        require(n > 0, "n must be greater than 0");
        uint256 size = n > topDonors.length ? topDonors.length : n;
        Donor[] memory result = new Donor[](size);

        for (uint256 i = 0; i < size; i++) {
            result[i] = topDonors[i];
        }

        return result;
    }

    

    
    // Fallback 函数 - 允许直接向合约转账
    receive() external payable {
        donate();
    }
}
