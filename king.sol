// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */


contract GMAE_KOET  {

    //目前的王
    address public king_current ;

    // 狀態
    State private state;
    enum State { Started, Ended }

    //管理員
    address owner;

    //檢查是王位是否為空
    bool first_send = true;


    //存取王的歷史資訊
    mapping (address => King_info)  kings_list;
   
    //王的資訊結構
    struct King_info {
        //地址
        address addr;
        //金額
        uint amount;
    }
    //建構子
    constructor() {
        owner = msg.sender;
        state = State.Started;
    }

    
    modifier game_IsStarted() { require(state == State.Started,"state error"); _; }

    //成為新王
    function replace() payable game_IsStarted public  {
        //設定最小值
        require(msg.value != 0 && msg.value >= 0.5 ether,"minimum error");
        //若已有王在列表上 1.不能自己替代自己 2.替代王需比目前金額高133%
        if(!first_send)
        {
            uint _HighestAmount = (kings_list[king_current].amount);
            uint _RequiredAmount  = _HighestAmount * 133/100 ;

            require(king_current != msg.sender,"duplicated error");
            require(msg.value >= _RequiredAmount  ,"insufficient_funds error");
            //將新王的錢給舊王 扣除0.05 ether 管理費
            payable(king_current).transfer(msg.value - 0.05 ether);
        }
        else
            first_send = false;
        //新增王資訊
        kings_list[msg.sender] = King_info(msg.sender, msg.value);
        king_current = msg.sender;
     

    }

    // 結束遊戲，回收管理費
    function recycling_fee ()  game_IsStarted public {
        require(msg.sender == owner,"wrong_person error");

        payable(owner).transfer(address(this).balance);

        state = State.Ended;
        
    }
    // 查看目前最高金額與所需最低篡位金額
    function checkHighestAmount() view game_IsStarted public returns(uint,uint)
    {
        uint _HighestAmount = (kings_list[king_current].amount);
        uint _RequiredAmount  = _HighestAmount * 133/100 ;
        return  (_HighestAmount,_RequiredAmount);
    }

}