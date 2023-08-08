// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MyToken is ERC721, ERC721Enumerable, Ownable, AccessControl, Pausable {

    // Contract-level variables
    string public contractURI; // URI for the contract metadata
    string private _baseTokenURI; // Base URI for token metadata
    uint256 private _tokenIdCounter; // Counter for token IDs

    // Role for the designated minter
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Events
    event NFTMinted(address indexed minterBy, address mintedTo, uint256 tokenId, string ipfsMetadata); 
    event NFTClaimed(address indexed claimer, address claimedTo, uint256 tokenId, string ipfsMetadata);

    // Constructor
    constructor(string memory initialBaseURI, string memory initialContractURI) ERC721("SPORTWORLD X ELF MyMOMENT EDITION", "SWELF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
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

    // Function to perform actions before token transfer (overrides ERC721Enumerable and ERC721)
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // Function to check supported interfaces (overrides multiple contracts)
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Function to get the token URI for a given token ID (overrides ERC721)
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI, "/", tokenId)) : "";
    }

    // Function to mint an NFT with specified metadata (accessible only by the designated minter)
    function mintNFT(address to, string calldata ipfsMetadata) external onlyMinter whenNotPaused {
        require(Address.isContract(to) == false, "Cannot send to contract address");
        require(bytes(ipfsMetadata).length != 0, "Invalid metadata");

        _safeMint(to, _tokenIdCounter);
        emit NFTMinted(msg.sender, to, _tokenIdCounter, ipfsMetadata);
        _tokenIdCounter++;
    }

    // Function to bulk mint NFTs with specified metadata (accessible only by the designated minter)
    function mintBulkNFTs(address[] calldata to, string[] calldata ipfsMetadataArray) external onlyMinter whenNotPaused {
        require(to.length == ipfsMetadataArray.length, "Mismatch between recipients and metadata");

        for (uint i = 0; i < to.length; i++) {
            require(Address.isContract(to[i]) == false, "Cannot send to contract address");
            require(bytes(ipfsMetadataArray[i]).length != 0, "Invalid metadata");

            _safeMint(to[i], _tokenIdCounter);
            emit NFTMinted(msg.sender, to[i], _tokenIdCounter, ipfsMetadataArray[i]);
            _tokenIdCounter++;
        }
    }

    // Function for users to claim their NFTs (accessible by the contract owner)
    function claimNFT(uint256 tokenId, address user, string calldata ipfsMetadata) external onlyOwner whenNotPaused {
        require(_exists(tokenId), "MyToken: NFT does not exist");
        safeTransferFrom(owner(), user, tokenId);
        emit NFTClaimed(user, user, tokenId, ipfsMetadata);
    }

    // Function to bulk transfer NFTs to a specified address (accessible only by the contract owner)
    function transferBulkNFTs(address to, uint256[] calldata tokenIds) external whenNotPaused {
        require(Address.isContract(to) == false, "Cannot send to contract address");
        require(tokenIds.length > 0, "No tokens specified");

        for (uint i = 0; i < tokenIds.length; i++) {
            require(_exists(tokenIds[i]), "MyToken: NFT does not exist");
            require(ownerOf(tokenIds[i]) == msg.sender, "MyToken: Caller is not owner");

            safeTransferFrom(msg.sender, to, tokenIds[i]);
        }
    }

    // Function to add a wallet as a minter (accessible only by the contract owner)
    function addMinter(address account) external onlyOwner {
        grantRole(MINTER_ROLE, account);
    }

    // Function to remove a wallet from the minter role (accessible only by the contract owner)
    function removeMinter(address account) external onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }

    // Function to pause the contract, disabling minting and transfer (accessible only by the contract owner)
    function pause() external onlyOwner {
        _pause();
    }

    // Function to unpause the contract, enabling minting and transfer (accessible only by the contract owner)
    function unpause() external onlyOwner {
        _unpause();
    }
}
