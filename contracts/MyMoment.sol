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
    uint256 private _tokenIdCounter; // Counter for token IDs
    uint96 private _royaltyFeesInBips; // Royalty fees in basis points (1/100th of a percent)

    // Role for the designated minter
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Events
    event MintNFT(address indexed minter, uint256 indexed tokenId, string ipfsMetadata); 
    event ClaimNFT(address indexed claimer, uint256 indexed tokenId, string ipfsMetadata);

    // Constructor
    constructor(uint96 royaltyFeesInBips, string memory initialBaseURI, string memory initialContractURI) ERC721("SPORTWORLD X ELF MyMOMENT EDITION", "SWELF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setRoyaltyFees(royaltyFeesInBips);
        _baseTokenURI = initialBaseURI;
        contractURI = initialContractURI;
    }

    // Modifier to restrict certain functions to the designated minter
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "MyToken: Caller is not a minter");
        _;
    }

    // Function to set the base URI for token metadata (accessible only by the contract owner)
    function setBaseTokenURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Function to set the contract URI (accessible only by the contract owner)
    function setContractURI(string calldata newContractURI) external onlyOwner {
        contractURI = newContractURI;
    }

    // Function to set the royalty fees in basis points (accessible only by the contract owner)
    function setRoyaltyFees(uint96 feesInBips) public onlyOwner {
        _royaltyFeesInBips = feesInBips;
    }

    // Function to perform actions before token transfer (overrides ERC721Enumerable)
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Function to check supported interfaces (overrides multiple contracts)
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, IERC2981, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Function to get royalty information for a token (implements IERC2981)
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        return (owner(), (salePrice * _royaltyFeesInBips) / 10000);
    }

    // Function to get the token URI for a given token ID (overrides ERC721)
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI, "/", tokenId)) : "";
    }

    // Function to mint an NFT with specified metadata (accessible only by the designated minter)
    function mintNFT(address to, string calldata ipfsMetadata) external onlyMinter {
        _safeMint(to, _tokenIdCounter);
        emit MintNFT(msg.sender, _tokenIdCounter, ipfsMetadata);
        _tokenIdCounter++;
    }

    // Function for users to claim their NFTs (accessible by any wallet designated as a minter)
    function claimNFT(uint256 tokenId, address user, string calldata ipfsMetadata) external onlyMinter {
        require(_exists(tokenId), "MyToken: NFT does not exist");
        approve(msg.sender, tokenId);
        safeTransferFrom(owner(), user, tokenId);
        emit ClaimNFT(user, tokenId, ipfsMetadata);
    }

    // Function to add a wallet as a minter (accessible only by the contract owner)
    function addMinter(address account) external onlyOwner {
        grantRole(MINTER_ROLE, account);
    }

    // Function to remove a wallet from the minter role (accessible only by the contract owner)
    function removeMinter(address account) external onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }
}
