// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Farmo
    {
        uint public investment = 50;
        uint output;
        uint public  profit = 0;
        uint public loss = 0;

       function Result() public view returns (uint,string memory)
        {
            uint output = Returns();

            if (output < investment)
                {   
                    uint loss = loss + (investment - output);
                    string memory  result = "Loss";
                    
                    return (loss,result);
                }
            else if (investment < output)
                {
                    string memory  result = "Profit";
                    uint profit = profit +( output - investment);
                    return (profit,result);
                }
            else 
                {
                    string memory result = "neither PROFIT nor LOSS";
                    return (0,result);
                }
        }
        


        function Returns() internal  view returns(uint)
            {
                uint randomOut =  uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % investment;

                if (randomOut%2==1)
                    {
                      uint finalOutput =  investment + randomOut;
                      if (finalOutput <= 10)
                        {
                           finalOutput += 15;
                           
                        }
                        return finalOutput;

                    }
                else 
                    {
                    uint finalOutput =  investment - randomOut;
                      if (finalOutput <= 10)
                        {
                           finalOutput += 15;                           
                        }
                        return finalOutput;
                    }
            }

        
        // function calProfit() external  view returns(uint)
        //     {
        //          uint calC = Returns() - investment;
        //         return calC;
        //     }
        // function calLoss() external  view returns (uint)
        //     {
        //         uint calC = (investment - Returns());
        //         return calC;
        //     }
            
            function ifProfit() public view returns(uint)

                {
                    return profit;
                }
            function ifLoss() public 
                {

                }
        
    }

