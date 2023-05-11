// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract etherTransac
    {
        address payable owner;
        uint InvestBalance = 0;
        mapping (address=>uint) public investAmount ;

        constructor() {
            owner =payable(msg.sender);
        }

        modifier moreThanZero
            {
                require(msg.value > 0,"Investment must more than Zero wei");
                _;
            }
        modifier isOwner
            {
                require(msg.sender == owner,"Bull shit You are not the owner");
                _;
            }

        function Invest() public  payable moreThanZero  
            {
                
                InvestBalance += msg.value;
                investAmount[msg.sender] += msg.value;
            }

        // receive() external  payable {}

        function getContractBal() public  view returns(uint)    
            {
               return  address(this).balance;
            }

        function InvestmentOver() public isOwner returns(uint)
            {
                owner.transfer(address(this).balance);
                return InvestBal();
            }

        function ownerBal() public  view returns(uint)
            {
                return owner.balance;
            }
        function InvestBal() public view returns(uint)  
        {
            return InvestBalance;
        }
    }
