// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing required OpenZeppelin contracts and interfaces
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

// Creating the main contract which inherits from ERC721, ERC721Enumerable, IERC2981, Ownable, and AccessControl
contract MyToken is ERC721, ERC721Enumerable, IERC2981, Ownable, AccessControl {

    // Public variable to store contract's URI
    string public contractURI;

    // Defining a constant role identifier for minters
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Events for minting and claiming NFTs
    event MintNFT(address minter, uint256 tokenId);
    event ClaimNFT(address claimer, uint256 tokenId);

    // Contract constructor that sets up the contract name, symbol, default admin role, royalty info and contract URI
    constructor(uint256 _royaltyFeesInBips, string memory _contractURI) ERC721("SPORTWORLD X ELF MyMOMENT EDITION", "SWELF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // Setting up default admin role
        setRoyaltyInfo(owner(), _royaltyFeesInBips);  // Setting royalty info
        contractURI = _contractURI;  // Setting contract URI
    }

    // Function to safely mint tokens, accessible only by those having the minter role
    function safeMint(address to, uint256 tokenId) external onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);  // Internal OpenZeppelin function for safe minting
        emit MintNFT(msg.sender, tokenId);  // Emitting the MintNFT event
    }

    // Function to claim NFTs, accessible by anyone
    function claimNFT(uint256 tokenId) external {
        _safeMint(msg.sender, tokenId); // Minting the NFT to the message sender
        emit ClaimNFT(msg.sender, tokenId);  // Emitting the ClaimNFT event
    }

    // Function to set royalty information, accessible only by contract owner
    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyOwner {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);  // Internal function to set default royalty
    }

    // Function to set contract URI, accessible only by contract owner
    function setContractURI(string calldata _contractURI) external onlyOwner {
        contractURI = _contractURI;  // Setting the contract URI
    }

    // Function to retrieve royalty information for a given token Id and sale price
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        return (_receiver, (_salePrice * _royaltyFeesInBips) / 10000);  // Calculating and returning royalty info
    }

    // Overriding the _beforeTokenTransfer function from ERC721 and ERC721Enumerable to define custom behavior
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);  // Calling the parent contract _beforeTokenTransfer function
    }

    // Overriding the supportsInterface function to determine which interfaces are supported by this contract
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, IERC2981, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);  // Calling the parent contract supportsInterface function
    }

    // Overriding the tokenURI function to retrieve the URI of a specific token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");  // Making sure the token exists
        return bytes(_tokenURI).length > 0 ? string(abi.encodePacked(_tokenURI, tokenId)) : "";  // Returning the token URI
    }
}