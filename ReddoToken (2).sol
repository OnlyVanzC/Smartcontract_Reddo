pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract ReddoToken is ERC721, Ownable {
    
    event Sent(address indexed payee, uint256 amount, uint256 balance);
    event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);
    
    uint256 private tokenId=1;
    uint256 public currentPrice;
    
    struct reddosarray{
        uint256[] Array;
    }
    
    mapping(address => reddosarray) reddosArray;
    
    mapping(uint256 => uint) startTime;
    
    //This contructor defines the token's name and symbol
    constructor () ERC721("Reddo", "REDO") public {
        
    }
    
    //This function is used to generate a unique tokeId so that every token is different
    function getTokenId() internal returns (uint) {
        return tokenId++;
    }
    
    //This function allow the user to buy token, once activated it will mint a new token and transfer it to the person who bought the token.
    function buyToken() public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= currentPrice);
        address tokenBuyer = msg.sender;
        uint256 tempTokenId = getTokenId();
        _safeMint(tokenBuyer, tempTokenId, "");
        reddosArray[msg.sender].Array.push(tempTokenId);
        startTime[tempTokenId] = now;
        emit Received(msg.sender, tempTokenId, msg.value, address(this).balance);
    }
    
    //This function transfer Reddo from x address to y address, tokenId must be included as well.
    function transferReddo(address from, address to, uint256 Id) public {
        burnReddo();
        if (reddosArray[msg.sender].Array.length > 0)
        safeTransferFrom(from, to, Id);
        startTime[Id] = now;
        reddosArray[to].Array.push(Id);
        for (uint j = 0; j < reddosArray[from].Array.length - 1; j++){
                    reddosArray[from].Array[Id] = reddosArray[msg.sender].Array[Id + 1];
        }
        reddosArray[from].Array.pop();
    }
    
    
    //This function checks the balance of Reddos 
    function balanceofReddo() public view returns (uint256) {
        uint256 tmp = balanceOf(msg.sender);
        uint256 tmpid;
        for (uint256 i = 0; i < tmp; i++) {
            tmpid = tokenByIndex(i);
            if (now >= startTime[reddosArray[msg.sender].Array[tmpid-1]] +  10 minutes) 
                tmp--;}
        return tmp;
    }
    
  
    
    //This function when activated will burn every token that have existed for a set period of time.
    function burnReddo() internal {
        for (uint i = 0; i < reddosArray[msg.sender].Array.length; i++) {
            if (now >= startTime[reddosArray[msg.sender].Array[i]] +  10 minutes) {
                _burn(reddosArray[msg.sender].Array[i]);
                for (uint j = 0; j < reddosArray[msg.sender].Array.length - 1; j++){
                    reddosArray[msg.sender].Array[i] = reddosArray[msg.sender].Array[i + 1];
                }
                reddosArray[msg.sender].Array.pop();
            }
        }
    }
    
    //This function sends the Ethereum stored in the contract to the owner of the contract
    function sendEthereumTo(address payable to, uint256 amount) public payable onlyOwner {
        require(to != address(0) && to != address(this));
        require(amount > 0 && amount <= address(this).balance);
        to.transfer(amount);
        emit Sent(to, amount, address(this).balance);
    }
    
    //This function set the price of the Reddo Token, only the contract owner can set it
    function setCurrentPrice(uint256 price) public onlyOwner {
        require(price > 0);
        currentPrice = price;
    }
}