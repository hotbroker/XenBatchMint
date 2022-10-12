// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface XENCryptoIf is IERC20
{
    function claimRank(uint256 term) external;
    function claimMintRewardAndShare(address other, uint256 pct) external;
}
contract KillerSub
{
    address creator;
    address ownerAddress;
    XENCryptoIf xenAddr;

    constructor(address XenAddress){
	    creator = tx.origin;
        ownerAddress = msg.sender ;
        xenAddr = XENCryptoIf(XenAddress);
    }

    function claimRank() external
    {
        xenAddr.claimRank(1);
    }
    function claimMintReward() external
    {
        xenAddr.claimMintRewardAndShare(creator,100);
    }

}
contract XenKiller  {

    address ownerAddress;

    constructor(){
        ownerAddress = msg.sender ;
        
    }

    struct MintInfo {
        address []mintaddress;
        
    }
    event newTmpContract(address tmpcontract);
    event claimContract(address tmpcontract);

    mapping(address => MintInfo)  usermint;



    function batchmint(uint8 amount,address XenAddress) external payable
    {
        uint8 freecnt=3;
        if(msg.sender != ownerAddress)
        {
            if(  amount>freecnt)
            {
                uint256 v2 = (amount-freecnt);
                v2 = v2*(1* 10**18)/100;
                
                require(msg.value>=v2, "has to pay");
            }
        }

        MintInfo storage info  = usermint[msg.sender];
        for(uint8 i=0; i<amount; i++)
        {
            KillerSub tmp = new KillerSub(XenAddress);
            tmp.claimRank();
            info.mintaddress.push(address(tmp));
            //emit newTmpContract(address(tmp));

        }
        usermint[msg.sender] = info;

    }

    function claimall() external
    {
        
        MintInfo memory info = usermint[msg.sender];
        for(uint i=0; i<info.mintaddress.length; i++)
        {
            address tmp = info.mintaddress[i];
            if(tmp==address(0))
                continue;
            KillerSub(tmp).claimMintReward();
            //emit claimContract(tmp);

        }
    }

    function mytransferErc20(address token, address to, uint256 amount) public {
        require(msg.sender == ownerAddress, "Only Owner");
        IERC20(token).transfer(to, amount);

    }

    fallback() external payable {}
    receive() external payable {}

    function withdraw() public {
        require(msg.sender == ownerAddress, "Only Owner");
        payable(msg.sender).transfer(address(this).balance );

    }



}
