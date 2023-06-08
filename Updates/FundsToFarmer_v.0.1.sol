// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract FundsToFarmer
    {
       
        uint TotalProfit ;
        uint TotalLoss;
    
        uint Investercount = 0;
        address payable owner;
        address[] iList;
        
        address payable sendTo;
        uint depositTotalAmount;

        uint public totalInvestAmt ;
        

        uint deployTime;
        uint endTime;

        struct InvesterData
            {
                address addr;
                string name;
                uint amt;                
                uint Investercount;
                
            }

        constructor () 
            {
                owner = payable(msg.sender);

                deployTime = block.timestamp; //1683804740
                endTime = deployTime + 90 seconds;
            }


/* ****************************** Mappings ************************************/
        mapping(address => InvesterData) investerInfo;
        mapping(address=>uint) Iamt;
        mapping(address=>bool) isInvester;

/* ****************************** Modifiers ************************************/

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
        modifier IstimeAvailabe
            {
                require(IstimeAvailabeToInvest() == true,"Time up to invest");
                _;
            }
        modifier IsInvestmentOver
            {
                require (IstimeAvailabeToInvest() == false,"Investment time not completed");
                _;
            }
            mapping(address => bool) isClaimed;

        modifier notClaimed
            {
                require(isClaimed[msg.sender] == false,"You already claimed your funds");
                _;
            }
        

            //****************** Helper Functions *************************
            
            
            function setBasisPoints() internal view returns(uint)
                {
                    uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
                    uint BasisPoints =  (InvestByInvester * 100)/ totalInvestAmt ;
                    return BasisPoints ;
                }
            // function InvesterNameByExternal(uint _num) external pure returns(string memory)
            //     {
            //         string memory str = Strings.toString(_num);
            //         return string.concat("Invester_",str);
            //     }
            function IstimeAvailabeToInvest() public  view returns (bool TimeAvailbilityIs)    
            {
                if(endTime < block.timestamp) 
                {
                    bool result = false;
                    return result;
                }
               else if(endTime > block.timestamp) 
                {
                    bool result = true;
                    return result;
                }
            }


        /* ******************************Investment Starts ************************************/

            function Invest(string memory _name) public payable moreThanZero IstimeAvailabe
                {
                InvesterData storage invester =  investerInfo[msg.sender] ;
                invester.addr = msg.sender;
                invester.amt  =  msg.value;      

                iList.push(invester.addr);
                totalInvestAmt += invester.amt;
                owner.transfer(invester.amt);
                invester.Investercount = ++Investercount;
                Iamt[invester.addr] = invester.amt;
                //invester.name = InvesterNameByExternal(invester.Investercount);
                invester.name = _name;
                isInvester[invester.addr] = true;              
                }

            
 
        function getInvestorDetails(address _addr) public view returns(address,string memory Name,uint Invested , uint Id)
            {
               InvesterData storage get =  investerInfo[_addr] ;
               uint amt = get.amt;
               uint iId = get.Investercount;
               string memory name = get.name;
               return (_addr,name,amt , iId);
            }

       
        // ***************** Investment Over ****************************
        function DepositAmount() public payable  onlyOwner IsInvestmentOver moreThanZero
                {
                    depositTotalAmount = msg.value;
                    
                }
            function shareProfitsToFarmer() public payable  onlyOwner notClaimed
                {
                    require(depositTotalAmount > totalInvestAmt ,"No Profits to share");
                    TotalProfit = address(this).balance - totalInvestAmt ;
                    uint QuarterProfit = TotalProfit  / 4 ;
                    owner.transfer(QuarterProfit);
                    TotalProfit -= QuarterProfit;
                }

        function WithdrawAmtToInvester() public payable IsInvester 
            {              
                sendTo = payable(msg.sender);
                uint sendAmt = Iamt[sendTo];
                sendTo.transfer(address(this).balance/2);
                Iamt[sendTo] -= sendAmt;

            }
        
	function ClaimFunds() public payable notClaimed returns(uint)
            {
                uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
                uint BP = setBasisPoints();
                address payable toInvester = payable(msg.sender) ;
                uint ShareToInvester;

            if (depositTotalAmount > totalInvestAmt)

                {   TotalProfit = (TotalProfit * BP);
                    ShareToInvester = (TotalProfit / 100) + InvestByInvester;
                    toInvester.transfer(ShareToInvester);
                }
            else if (depositTotalAmount < totalInvestAmt)
                {
                    TotalLoss = totalInvestAmt - depositTotalAmount;
                    TotalLoss = (TotalLoss * BP);
                    ShareToInvester = InvestByInvester - (TotalLoss / 100) ;
                    toInvester.transfer(ShareToInvester);
                }
                isClaimed[msg.sender]=true;

                return (ShareToInvester);
            }

        

        function Result() public view returns (uint ResultIs,string memory StatusIs)
            {
            
                if (depositTotalAmount < totalInvestAmt)
                    {   
                        uint Loss = totalInvestAmt - address(this).balance;
                        string memory  result = "Loss";
                        return (Loss,result);
                    }
                else if (depositTotalAmount > totalInvestAmt)
                    {
                        string memory  result = "Profit";
                        uint profit = address(this).balance - totalInvestAmt;
                        return (profit,result);
                    }
                else 
                    {
                        string memory result = "neither PROFIT nor LOSS";
                        return (0,result);
                    }
            }
        


    }
    
        
