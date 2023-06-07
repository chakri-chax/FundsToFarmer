// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/Strings.sol";

contract FundsToFarmer {
    uint investment;
    uint public TotalProfit;
    

    uint Investercount = 0;
    address payable owner;
    address[] iList;

    address payable sendTo;
    uint depositTotalAmount;

    uint public totalInvestAmt;

    uint deployTime;
    uint endTime;

    struct InvesterData {
        address addr;
        string name;
        uint amt;
        uint Investercount;
    }
    
    mapping(address => InvesterData) investerInfo;
    mapping(address => uint) Iamt;
    mapping(address => bool) isInvester;

    constructor() {
        owner = payable(msg.sender);

        deployTime = block.timestamp; //1683804740
        endTime = deployTime + 30 seconds;
    }
   // ****************************************** MODIFIERS **************************************************
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not a owner");
        _;
    }
    modifier IsInvester() {
        require(
            isInvester[msg.sender] == true,
            "Sorry, you are not a Invester"
        );
        _;
    }
    modifier moreThanZero() {
        require(msg.value >= 0, "Invest must be more than 0 wei");
        _;
    }
    modifier IstimeAvailabe() {
        require(timeAvailabeToInvest() == true, "Time up to invest");
        _;
    }
    modifier IsInvestmentOver() {
        require(
            timeAvailabeToInvest() == false,
            "Investment time not completed"
        );
        _;
    }
    //*****************************************************************************************************
    // ****************************************** EVENTS **************************************************
    event DepositBy(address from, uint256 amount);
    event InvestBy(address from, uint256 amount);
    event shareProfitsToFarmerBy(uint256 amount);
    event ShareDetails(address from, uint256 amount);

    //*****************************************************************************************************
    

    function Invest() public payable moreThanZero IstimeAvailabe {
        InvesterData storage invester = investerInfo[msg.sender];
        invester.addr = msg.sender;
        invester.amt = msg.value;

        iList.push(invester.addr);
        totalInvestAmt += invester.amt;
        owner.transfer(invester.amt);
        invester.Investercount = ++Investercount;
        Iamt[invester.addr] = invester.amt;
        invester.name = InvesterNameByExternal(invester.Investercount);
        isInvester[invester.addr] = true;

        emit InvestBy(invester.addr, invester.amt);
    }

    function DepositAmount()
        public
        payable
        onlyOwner
        IsInvestmentOver
        moreThanZero
    {
        depositTotalAmount = msg.value;
        TotalProfit = address(this).balance - totalInvestAmt;
        emit DepositBy(owner, depositTotalAmount);
    }

    function shareProfitsToFarmer() public payable onlyOwner {
        uint QuarterProfit = TotalProfit / 4;
        owner.transfer(QuarterProfit);
        TotalProfit -= QuarterProfit;
        emit shareProfitsToFarmerBy(QuarterProfit);
    }

    function WithdrawAmtToInvester() public payable IsInvester {
        sendTo = payable(msg.sender);
        uint sendAmt = Iamt[sendTo];

        sendTo.transfer(address(this).balance / 2);

        Iamt[sendTo] -= sendAmt;
    }

    function invstPer() public view returns (uint) {
        uint InvestByInvester = Iamt[msg.sender]; //Iamt[invester.addr]
        uint investerPercentage = ((InvestByInvester * 100));

        uint256 divPer = investerPercentage / totalInvestAmt;
        return divPer;
    }

    function setBasisPoints() public view returns (uint) {
        uint InvestByInvester = Iamt[msg.sender]; //Iamt[invester.addr]
        uint BasisPoints = (InvestByInvester * 100) / totalInvestAmt;
        return BasisPoints;
    }

    function TotalAmountShareToInvester() public payable IsInvester {
        address investor = msg.sender;
        uint InvestByInvester = Iamt[msg.sender]; //Iamt[invester.addr]
        uint BP = setBasisPoints();
        uint TotalProfit = (TotalProfit * BP);
        uint ShareToInvester = (TotalProfit / 100) + InvestByInvester;

        address payable toInvester = payable(msg.sender);
        toInvester.transfer(ShareToInvester);

        emit ShareDetails(investor, ShareToInvester);
    }

    function getInvestorDetails(
        address _addr
    ) public view returns (address, string memory, uint, uint) {
        InvesterData storage get = investerInfo[_addr];
        uint amt = get.amt;
        uint iId = get.Investercount;
        string memory name = get.name;
        return (_addr, name, amt, iId);
    }

    function InvesterNameByExternal(
        uint _num
    ) internal pure returns (string memory) {
        string memory str = Strings.toString(_num);
        return string.concat("Invester_", str);
    }

    // ***************** Investment Over ****************************

    function timeAvailabeToInvest() public view returns (bool) {
        if (endTime < block.timestamp) {
            bool result = false;
            return result;
        } else if (endTime > block.timestamp) {
            bool result = true;
            return result;
        }
    }
}
