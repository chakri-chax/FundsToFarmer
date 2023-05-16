// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/Strings.sol";

contract FundsToFarmer
    {
        uint investment;
        uint public TotalProfit ;
        uint loss = 0 ether;
        


        uint Investercount = 0;
        address payable owner;
        address[] iList;
        
        address payable sendTo;
        uint depositTotalAmount;

        uint public totalInvestAmt ;
        uint profitAmt = 5 ether;
        uint lossAmt = 5 ether;


        uint deployTime;
        uint endTime;

        struct InvesterData
            {
                address addr;
                string name;
                uint amt;                
                uint Investercount;
                
            }
        mapping(address => InvesterData) investerInfo;
        mapping(address=>uint) Iamt;
        mapping(address=>bool) isInvester;

        constructor () 
            {
                owner = payable(msg.sender);

                deployTime = block.timestamp; //1683804740
                endTime = deployTime + 30 seconds;
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
        modifier IstimeAvailabe
            {
                require(timeAvailabeToInvest() == true,"Time up to invest");
                _;
            }
        modifier IsInvestmentOver
            {
                require (timeAvailabeToInvest() == false,"Investment time not completed");
                _;
            }

            //****************** Helper Functions *************************
            function toWei(uint _eth) public view returns (uint)
                {
                    return _eth * 1e18;
                }
            function OnePerCentdiv() public view returns (uint)
                {
                    uint per1 =  totalInvestAmt/100 ;
                    return per1;
                }

        function Invest() public payable moreThanZero IstimeAvailabe
            {
              InvesterData storage invester =  investerInfo[msg.sender] ;
              invester.addr = msg.sender;
              invester.amt  =  msg.value;      

              iList.push(invester.addr);
              totalInvestAmt += invester.amt;
              owner.transfer(invester.amt);
              invester.Investercount = ++Investercount;
              Iamt[invester.addr] = invester.amt;
              invester.name = InvesterNameByExternal(invester.Investercount);
              isInvester[invester.addr] = true;              
            }

            function DepositAmount() public payable  onlyOwner IsInvestmentOver moreThanZero
                {
                    depositTotalAmount = msg.value;
                    TotalProfit = address(this).balance - totalInvestAmt ;
                }
            function shareProfitsToFarmer() public payable  onlyOwner
                {
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
        function invstPer() public view returns(uint)
                {
                    uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
			        uint investerPercentage = ((InvestByInvester * 100)) ;

                    uint256 divPer = investerPercentage  /totalInvestAmt;
                    return divPer;

                }
        function setBasisPoints() public view returns(uint)
			{
                uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
				uint BasisPoints =  (InvestByInvester * 100)/ totalInvestAmt ;
				return BasisPoints ;
			}
	function TotalAmountShareToInvester() public payable returns(uint)
		{
			uint InvestByInvester = Iamt[msg.sender];//Iamt[invester.addr]
            uint BP = setBasisPoints();
            uint TotalProfit = (TotalProfit * BP);
            uint ShareToInvester = (TotalProfit / 100) + InvestByInvester;
            address payable toInvester = payable(msg.sender) ;
            toInvester.transfer(ShareToInvester);

			// uint investerPercentage = ((InvestByInvester * 100)/totalInvestAmt) ;

			// uint percentShare = investerPercentage * TotalProfit ;
			// uint profitShare = percentShare /100;
			// uint totalAmtToInvester = profitShare + InvestByInvester;
			return (ShareToInvester);
		}
        


        function getInvestorDetails(address _addr) public view returns(address,string memory ,uint , uint)
            {
               InvesterData storage get =  investerInfo[_addr] ;
               uint amt = get.amt;
               uint iId = get.Investercount;
               string memory name = get.name;
               return (_addr,name,amt , iId);
            }

       function InvesterNameByExternal(uint _num) internal view returns(string memory)

        {
            string memory str = Strings.toString(_num);
            return string.concat("Invester_",str);
        }

        // ***************** Investment Over ****************************

        function timeAvailabeToInvest() public  view returns (bool)    
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
           

            
            // function ProfitOrLoss(bool _setResult , uint _setAmt) public view returns(uint)
            //     {
            //         if( _setResult == true)
            //             {
            //                 return _setAmt;
            //             }
            //         else if(_setResult == false)
            //             {
            //                 return 100;
            //             }
            //     }



        function Result() public view returns (uint,string memory)
        {
            uint output = 15 ether;
            uint profit;

            if (output < totalInvestAmt)
                {   
                    uint loss = loss + (investment - output);
                    string memory  result = "Loss";
                   // transferLoss();

                    
                    return (loss,result);
                }
            else if (investment < output)
                {
                    string memory  result = "Profit";
                    uint profit = profit +( output - investment);
                    //transferProfits();
                    return (profit,result);
                }
            else 
                {
                    string memory result = "neither PROFIT nor LOSS";
                    return (0,result);
                }
        }
        


        // function Returns() public  view returns(uint)
        //     {
        //         uint randomOut =  uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % investment;

        //         if (randomOut%2==1)
        //             {
        //               uint finalOutput =  investment + randomOut;
        //               if (finalOutput <= 10)
        //                 {
        //                    finalOutput += 15;
                           
        //                 }
        //                 return finalOutput;

        //             }
        //         else 
        //             {
        //             uint finalOutput =  investment - randomOut;
        //               if (finalOutput <= 10)
        //                 {
        //                    finalOutput += 15;                           
        //                 }
        //                 return finalOutput;
        //             }
        //     }

 } 


    

    
        // function getAmtByAddress0() public view returns(uint)
        //     {

        //        address sendTo = iList[0];
        //        uint  showAmt = Iamt[sendTo];
        //         return showAmt;

        //     }

    contract Sharing
        {
            address payable owner;
            address payable invester;
            uint public investAmt;
            uint public depositAmt;
            uint output;
            uint public profit;
            uint loss;
            mapping(address=>uint) iAmt;
            constructor ()
                {
                    owner = payable(msg.sender);
                }
            function toWei(uint _eth) public view returns (uint)
                {
                    return _eth * 1e18;
                }

            function Invest() public payable
                {
                    owner.transfer(msg.value);
                    investAmt += msg.value;
                    iAmt[msg.sender] = msg.value;
                }
            function getAmtByIn(address _addr) public view returns(uint)
                {
                    _addr = msg.sender;
                   return  iAmt[_addr] ;
                }

           fallback() external payable {}
           address payable _to;
           uint public TotalProfit ;
           uint public profitToFarmer ;
           uint contractBal;

            function deposit() public payable

                {   depositAmt = msg.value;
                    _to = payable(address(this));
                    _to.transfer(msg.value);
                    TotalProfit = address(this).balance - investAmt ;
                   
                }
         

            

            function shareToOwner() public payable 
                {
                    uint QuarterProfit = TotalProfit  / 4 ;
                    owner.transfer(QuarterProfit);
                    TotalProfit -= QuarterProfit;
                }
                
            function sharePerInv() public view returns(uint)
                {
                 uint  seedAmt =  2;
                 uint percentage = (seedAmt / 6 ) * 100 ;

                 uint profitShare = (percentage / 100) * 2;
                 uint shareAmt = seedAmt + profitShare;          
                 return percentage;

                }



            
            
        }
