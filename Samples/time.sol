// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

contract timeCal
    {
        uint deployTime;
        uint endTime;
        uint nonce = 0;
        constructor() {
          deployTime = block.timestamp; //1683804740
          endTime = deployTime + 7 seconds;


        }
        function timeCheck() public  view returns (string memory)    
            {
                if(endTime < block.timestamp) 
                {
                    return "Time Over";
                }
               else if(endTime > block.timestamp) 
                {
                    return "You have time to invest";
                }
            }

        function deployTime_() public view returns(uint)
            {
                return deployTime;
            }

        function EndTime() public view returns(uint)
            {
                return deployTime + 7 seconds;
            }
      
        function PresentTime() public view  returns (uint)
            {
                return block.timestamp ;
            }
        
//             function random() internal returns (uint) {
//     uint random = uint(keccak256(now, msg.sender, nonce)) % 1000;
//     nonce++;
//     return random;
// }
        function random() private view returns(uint){
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, endTime)));
}
        
    }
