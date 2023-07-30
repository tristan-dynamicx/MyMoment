// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract MyToken is ERC721, ERC721Enumerable, IERC2981, Ownable, AccessControl {
    // Contract-level variables
    string public contractURI; // URI for the contract metadata
    string private _baseTokenURI; // Base URI for token metadata
    uint256 private _tokenIdCounter; // Counter to keep track of the next token ID
    uint96 private _royaltyFeesInBips; // Royalty fees in basis points (bips)

    // Access control role definition
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Events for minting and claiming NFTs
    event MintNFT(address indexed minter, uint256 indexed tokenId, string mintedBy, string ipfsMetadata);
    event ClaimNFT(address indexed claimer, uint256 indexed tokenId, string mintedBy, string ipfsMetadata);

    // Contract constructor
    constructor(uint96 royaltyFeesInBips, string memory initialBaseURI, string memory initialContractURI) ERC721("SPORTWORLD X ELF MyMOMENT EDITION", "SWELF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // Set the contract deployer as the default admin
        _setRoyaltyFees(royaltyFeesInBips); // Set the royalty fees
        _baseTokenURI = initialBaseURI; // Set the base URI for token metadata
        contractURI = initialContractURI; // Set the URI for contract metadata
    }

    // Modifier to restrict access to functions to only minters
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "MyToken: Caller is not a minter");
        _;
    }

    // Function to set the base URI for token metadata, accessible only by the contract owner
    function setBaseTokenURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Function to set the URI for contract metadata, accessible only by the contract owner
    function setContractURI(string calldata newContractURI) external onlyOwner {
        contractURI = newContractURI;
    }

    // Function to set the royalty fees, accessible only by the contract owner
    function setRoyaltyFees(uint96 feesInBips) public onlyOwner {
        _royaltyFeesInBips = feesInBips;
    }

    // Override _beforeTokenTransfer to provide custom behavior on token transfers
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Override supportsInterface to include additional interfaces supported by this contract
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, IERC2981, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Implement royaltyInfo to calculate royalty information for a given token and sale price
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        return (owner(), (salePrice * _royaltyFeesInBips) / 10000);
    }

    // Override tokenURI to construct the full URI for a given token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI, tokenId)) : "";
    }

    // Function to mint NFTs, accessible only by minters
    function mintNFT(address to, string calldata mintedBy, string calldata ipfsMetadata) external onlyMinter {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        emit MintNFT(msg.sender, tokenId, mintedBy, ipfsMetadata);
        _tokenIdCounter++;
    }

    // Function to claim NFTs, accessible by anyone
    function claimNFT(string calldata mintedBy, string calldata ipfsMetadata) external {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(msg.sender, tokenId);
        emit ClaimNFT(msg.sender, tokenId, mintedBy, ipfsMetadata);
        _tokenIdCounter++;
    }

    // Function to add a new minter, accessible only by the contract owner
    function addMinter(address account) external onlyOwner {
        grantRole(MINTER_ROLE, account);
    }

    // Function to remove a minter, accessible only by the contract owner
    function removeMinter(address account) external onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }
}
