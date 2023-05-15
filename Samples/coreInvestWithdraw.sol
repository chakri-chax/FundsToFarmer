// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/Strings.sol";

contract InvesterList
    {
        
        uint count = 0;
        address payable owner;
        address[] iList;
        uint public toatalInvestAmt;
        address payable sendTo;
        uint depositTotalAmount;


        struct InvesterData
            {
                address addr;
                string name;
                uint amt;                
                uint count;
                
            }
        mapping(address => InvesterData) investerInfo;
        mapping(address=>uint) Iamt;
        mapping(address=>bool) isInvester;
        constructor () 
            {
                owner = payable(msg.sender);
            }
        modifier onlyOwner()
            {
                require(msg.sender == owner,"You are not a owner");
                _;
            }
        modifier IsInvester()
            {
                require(isInvester[msg.sender]==true,"Sorry, you are not a Invester");
                _;
            }
        modifier moreThanZero()
            {
                require(msg.value >= 0,"Invest must be more than 0 wei");
                _;
            }

        function Invest() public payable moreThanZero
            {
              InvesterData storage invester =  investerInfo[msg.sender] ;
              invester.addr = msg.sender;
              invester.amt  =  msg.value;      

              iList.push(invester.addr);
              toatalInvestAmt += invester.amt;
              owner.transfer(invester.amt);
              invester.count = ++count;
              Iamt[invester.addr] = invester.amt;
              invester.name = InvesterNameByExternal(invester.count);
              isInvester[invester.addr] = true;              
            }

            function DepositAmount() public payable  onlyOwner
                {
                    depositTotalAmount = msg.value;
                }

        function WithdrawAmt() public payable IsInvester
            {              
                sendTo = payable(msg.sender);
                uint sendAmt = Iamt[sendTo];
                sendTo.transfer(sendAmt);
                Iamt[sendTo] -= sendAmt;

            }
        
        // function getAmtByAddress0() public view returns(uint)
        //     {

        //        address sendTo = iList[0];
        //        uint  showAmt = Iamt[sendTo];
        //         return showAmt;

        //     }

        function getInvestorDetails(address _addr) public view returns(address,string memory ,uint , uint)
            {
               InvesterData storage get =  investerInfo[_addr] ;
               uint amt = get.amt;
               uint iId = get.count;
               string memory name = get.name;
               return (_addr,name,amt , iId);
            }

       function InvesterNameByExternal(uint _num) internal view returns(string memory)
        {
            string memory str = Strings.toString(_num);
            return string.concat("Invester_",str);
        }

    }
