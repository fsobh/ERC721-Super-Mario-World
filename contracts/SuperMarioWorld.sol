pragma solidity ^0.6.7;

import "./ERC721.sol";

contract SuperMarioWorld is ERC721 {

    string public name; //ERC721 Metadata

    string public symbol; //ERC721 Metadata

    uint256 public tokenCount;

    mapping(uint256=> string) private tokenURIs;

    constructor(string memory _name, string memory _symbol) public {

        name = _name;
        symbol = _symbol;
    }

    //tokenURI (points to metadata)
    function tokenURI(uint256 tokenId) public view returns (string memory /*(Explicit data location)*/){ //ERC721 Metadata
        require(_owners[tokenId] != address(0), "Token Does Not Exist"); // _owners was inherited from ERC721

        return tokenURIs[tokenId];
    }

    //Creates a new NFT 
    function mint(string memory _tokenURI) public {

        tokenCount++;

        _balances[msg.sender]++;

        _owners[tokenCount] = msg.sender;

        tokenURIs[tokenCount] = _tokenURI;

        emit Transfer(address(0), msg.sender, tokenCount);

    }

    //supports interface
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool){
        return interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f; // for opensea to pick up the Contracts meta data like name and symbol
    }
}