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
        bool deposited = false;
        bool Isinvested;

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
                endTime = deployTime + 30 seconds;
            }


/* ****************************** Mappings ************************************/
        mapping(address => InvesterData) investerInfo;
        mapping(address=>uint) Iamt;
        mapping(address=>bool) isInvester;

        event DepositBy(address from, uint256 amount);
        event InvestBy(address from, uint256 amount);
        event shareProfitsToFarmerBy(uint256 amount);
        event ClaimedDetailsOfInvestor(address from, uint256 amount);

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
                require(msg.value > 0,"Amount must be more than 0 wei");
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


        modifier IsDeposited()
            {
                require(deposited == true,"Funds Not Yet Deposit by Farmer");
                _;
            }

            bool profitTakenByFarmer = false;

            modifier ProfitTakenByFarmer()
            {
                require(profitTakenByFarmer==false,"You already took the profit, Dont act smart aa!!");
                _;
            }
            bool isProfit = false;

        modifier IsProfitCame()
            {
                require (isProfit == true,"Profits not available");
                _;
            }

        modifier allInvestersTaken()
            {
                (Investercount == 0,"Investers still yet not taken Funds");
                _;
            }
            mapping (address => bool) isHeInvest;

        modifier OneTimeInvestment()
            {
                require(isHeInvest[msg.sender]==false,"Only One Time investemt accepted");
                _;
            }

        /* ******************************Investment Starts ************************************/

            function _1_Invest(string memory _name) public payable moreThanZero IstimeAvailabe OneTimeInvestment
                {

                require(msg.sender != owner,"Owners not allowed to Invest,sorry");
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
                isHeInvest[msg.sender] = true;

                emit InvestBy(msg.sender,msg.value)    ;    
                }

       
        function _2_DepositAmount() public payable  onlyOwner IsInvestmentOver moreThanZero 
                {
                    require(deposited==false,"Already Deposited");
                    depositTotalAmount = msg.value;
                    deposited = true;
                    

                    emit DepositBy(owner,depositTotalAmount);
                    
                }
            function _3_shareProfitsToFarmer() public payable  onlyOwner notClaimed ProfitTakenByFarmer
                {
                    require(depositTotalAmount > totalInvestAmt ,"No Profits to share");
                    TotalProfit = address(this).balance - totalInvestAmt ; 
                    uint QuarterProfit = TotalProfit  / 4 ;
                    owner.transfer(QuarterProfit);
                    TotalProfit -= QuarterProfit;
                    profitTakenByFarmer = true;

                    
                    emit shareProfitsToFarmerBy(QuarterProfit);
                }

        
        
	function _4_ClaimFunds() public payable notClaimed IsInvester IsDeposited  returns(uint)
            {
                
                require(msg.sender != owner, "Owners not allowed");
                uint ShareToInvester;

            if (depositTotalAmount > totalInvestAmt)

                {
                require(profitTakenByFarmer == true,"profit not yet Taken by Farmer");
                address investor = msg.sender;
                uint InvestByInvester = Iamt[msg.sender]; //Iamt[invester.addr]
                uint BP = setBasisPoints();
                uint TotalProfit = (TotalProfit * BP);
                uint ShareToInvester = (TotalProfit / 1000000000000000000) + InvestByInvester;

                address payable toInvester = payable(msg.sender);
                toInvester.transfer(ShareToInvester);
                isClaimed[msg.sender]=true;

                emit ClaimedDetailsOfInvestor(msg.sender,ShareToInvester);

                }
            else if (depositTotalAmount < totalInvestAmt)
                {
                    uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
                    uint BP = setBasisPoints();
                    address payable toInvester = payable(msg.sender) ;
                    uint ShareToInvester;

                    TotalLoss = totalInvestAmt - depositTotalAmount;
                    TotalLoss = (TotalLoss * BP);
                    ShareToInvester = InvestByInvester - (TotalLoss / 1000000000000000000) ;
                    toInvester.transfer(ShareToInvester);
                    isClaimed[msg.sender]=true;
                    emit ClaimedDetailsOfInvestor(msg.sender,ShareToInvester);
 
                }
                

                return (ShareToInvester);
            }
            function _5_FlushToFarmer() public payable onlyOwner moreThanZero
            {              
                sendTo = payable(owner);
                sendTo.transfer(address(this).balance);

            }

        
            //****************** Helper Functions *************************
            
        function getInvestorDetails(address _addr) public view returns(address,string memory Name,uint Invested , uint Id)
            {
               InvesterData storage get =  investerInfo[_addr] ;
               uint amt = get.amt;
               uint iId = get.Investercount;
               string memory name = get.name;
               return (_addr,name,amt , iId);
            }
            
            function setBasisPoints() internal view returns(uint)
                {
                    uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
                    uint BasisPoints =  (InvestByInvester * 1000000000000000000)/ totalInvestAmt ;
                    return BasisPoints ;
                }
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
    
        
