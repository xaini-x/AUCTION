// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
import "./transfer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./erc721.sol";
contract Auction is ERC721, Ownable {
    MyToken private token;
   
    mapping(address => uint256) private Index;
    mapping(uint256 => bool) private ids;
    uint256 charge = 0.5 ether;
    bool exist = true;
    mapping(uint256 => uint256) private startTime;
    mapping(uint256 => uint256) private minimumbid;
    mapping(uint256 => uint256) private endTime;
uint tokensPerEther = 1;
    uint256 private totalauctioncharge;
  

    constructor(address _token) ERC721("", "") {
        // owner() = payable(msg.sender);
        token = MyToken(_token);
    }

    // mintid address != sponser address ---------------------
    function MintID(uint256 id) public {
        _mint(msg.sender, id);
        emit ItemDetail(msg.sender, id);
    }

        function swapToken() external payable {
        require(msg.value > 0, "Buy Token: Need to send some amount of ether");          // ether should be more than zero
        uint tokensToBuy = msg.value ;                    //no.of token need to buy is depend on calculation
       payable(owner()).transfer(msg.value);
        token.transferFrom(owner(), msg.sender, tokensToBuy);
    }


    function swapBack(uint256 amount) external payable {
        address payable to = payable(msg.sender); 
        to.transfer(amount);
        token.transferFrom(owner(), msg.sender, amount);
    }

    function startAuction(
        uint256 id,
        uint256 minimumBid,
        uint256 endT
    ) public  {
        require(
            getApproved(id) == address(this),
            " not approved to owner"
        );
        ids[id] = true;
        startTime[id] = block.timestamp;
        minimumbid[id] = minimumBid;
        endTime[id] =  endT;
        emit AUCTIONSTART(startTime[id], minimumBid, endTime[id]);
    }

    // transfer id to bidder and money to id owner--------------

    function WinnerDeclare(
        uint256 id,
        address from,
        uint256 amount
    ) public  {
        require (ownerOf(id) == msg.sender ," only owner");
        // require(block.timestamp > endTime[id] , "  time not over");
        uint256 auctionprice = (amount * 5) / 100;
        uint256 _pay = amount - auctionprice;
        token.transferFrom(from, ownerOf(id), _pay);
        transferFrom(ownerOf(id), from, id);
        token.transferFrom(from, owner(), auctionprice);
        ids[id] = false;
        emit TransferDetail(id, from, amount);
    }

    function AuctionCancel(uint256 id, address to) public {
        require(ownerOf(id) == msg.sender && ids[id] == true," not the owner or no auction start");
        token.transferFrom(ownerOf(id), to, charge);
        ids[id] = false;
    }

    // transfering money to the given (reciver)address in constructor
    function withdraw() public {
        require(msg.sender == owner(), "");
        payable(owner()).transfer(address(this).balance);
    }

    event ItemDetail(address owner, uint256 itemId);
    event AUCTIONSTART(uint256 startTime, uint256 minimumBID, uint256 endTime);
    event TransferDetail(
        uint256 TransferID,
        address newOwner,
        uint256 transferedAmount
    );
}
