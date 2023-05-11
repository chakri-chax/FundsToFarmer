// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Farmo
    {
        uint public investment = 50;
        uint public output = 100;

       function checking() public view returns (uint,string memory)
        {
            if (investment > output)
                {
                    string memory  result = "Loss";
                    return (this.calLoss(),result);
                }
            else if (investment < output)
                {
                    string memory  result = "Profit";
                    return (this.calProfit(),result);
                }
            else 
                {
                    string memory result = "neither PROFIT nor LOSS";
                    return (0,result);
                }
        }

        function calProfit() external  view returns(uint)
            {
                 uint calC = output - investment;
                return calC;
            }
        function calLoss() external  view returns (uint)
            {
                uint calC = investment - output;
                return calC;
            }
    }
