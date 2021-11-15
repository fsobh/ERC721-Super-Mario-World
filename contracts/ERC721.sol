pragma solidity ^0.6.7;

contract ERC721 {

    //making it internal becasue were gonna use it later when we inherit

    // balance of the wallets
    mapping(address => uint256) internal _balances;

    //owners of the Tokens
    mapping(uint256 => address) internal _owners;
   
    //accounts allowed to operate on another accounts assets
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    //Current address that is approved to operate on token
    mapping(uint256 => address) private _tokenApprovals; // (can only have 1 approved address per token)


     event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

     event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

     event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    //Returns a number of NFT's assigned to an owner
    function balanceOf(address owner) public view returns (uint256){

        require(owner != address(0), "Owner Zero Address");

        return _balances[owner];

    }

    //Returns the owner of an NFT
    function ownerOf(uint256 tokenId) public view returns (address){

        address owner = _owners[tokenId];

        require(owner != address(0), "Token ID does not exist"); // because mapping assumes everything exists and is initialized to false or 0

        return owner;
    }

    //Enables or disables an operator to manage ALL of msg.sender's assets
     function setApprovalForAll(address operator, bool approved) public {
        
        require(operator != address(0), "Operator Zero Address");

        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender,operator,approved);


     }

    //checks if an address is approved to be an operator by another address
     function isApprovedForAll(address owner, address operator) public view returns (bool){

         require(operator != address(0) && owner != address(0) , "Owner/Operator Zero Address");

         return _operatorApprovals[owner][operator];

     }
    
     //Same as transferFrom function, checks is onERC721Recieved is implemented WHEN sending to smart contract (dont need to do this if sending to a wallet like meta mask)
     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {

         transferFrom(from,to,tokenId);

         require(_checkOnERC721Recieved(), "Reciever not implemented for Reciever");

     }
    //same as above but with out bytes
     function safeTransferFrom(address from, address to, uint256 tokenId) public {
         safeTransferFrom(from,to,tokenId, "");
     }

    //Transferes ownership of an NFT
     function transferFrom(address from, address to, uint256 tokenId) public {

        require(to != address(0) && from != address(0) , "Sender/Reciever Zero Address");

        address owner = ownerOf(tokenId);

        require(owner != address(0) && //owner != address(0) --> make sure token ID exists
                        (

                         msg.sender == owner || //sender is  the owner
                         msg.sender == getApproved(tokenId) || //sender is approved to operate on this particular token
                         isApprovedForAll(owner, msg.sender)  // sender is one of the approved wallets that can operate on the token
                         
                         ) ,"Address not authorized to operate on Token");

        
        require(owner == from , "Not being sent from the owner"); //make sure the from parameter is = to the owner of the NFT               

        approve(address(0),tokenId); // Clear the approval list for this token

        //updated balances 
        _balances[from] -= 1 ;
        _balances[to]   += 1 ;

        //update token ownership
        _owners[tokenId] = to;

        emit Transfer(from,to,tokenId);

     }

     // Updates an approved address
     function approve(address to, uint256 tokenId) public {

        require(to != address(0), "Operator Zero Address");

        address owner = ownerOf(tokenId);

        require(owner != address(0) && 
                                    (
                                    
                                    msg.sender == owner || 
                                    isApprovedForAll(owner, msg.sender)
                                    
                                    ) , "Address not approved to operate on Token");

        _tokenApprovals[tokenId] = to;

        emit Approval(owner,to,tokenId);

     }
    
    
     //gets approved address for a single token
     function getApproved(uint256 tokenId) public view returns (address){

        require(_owners[tokenId] != address(0), "Zero Address");
        return _tokenApprovals[tokenId];
     }

   
//Dummy function (usually you want to pull the reciever contract and instigate the function to see if you get a response back)
function _checkOnERC721Recieved() private pure returns(bool){

    return true;
}

//EIP 165 : Check if a contract implements another interface
function supportsInterface(bytes4 interfaceId) public pure virtual returns(bool){

return interfaceId == 0x80ac58cd; // <-- This is found in EIP 721 documentation - OpenSea uses this

}


}