// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MyToken is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    AccessControl,
    Pausable
{
    // Contract-level variables
    string public contractURI;
    string public baseURI;
    uint256 private _tokenIdCounter;
    uint256 public metadataHashLenght;

    // Role for the designated minter
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Events
    event NFTMinted(
        address indexed minterBy,
        address mintedTo,
        uint256 tokenId,
        string ipfsMetadata
    );
    event BulkMintedNFTs(
        address indexed minterBy,
        address mintedTo,
        uint256[] tokenIds,
        string ipfsMetadata
    );
    event UpdatedBaseURI(string baseURI, address updatedBy);
    event UpdatedMetadataHashLength(
        uint256 metadataHashLenght,
        address updatedBy
    );

    // Constructor
    constructor(
        string memory initialBaseURI,
        string memory initialContractURI
    ) ERC721("SPORTWORLD X ELF MyMOMENT EDITION", "SWELF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        baseURI = initialBaseURI;
        contractURI = initialContractURI;
        metadataHashLenght = 59;
    }

    // Modifier to restrict certain functions to the designated minter
    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "MyToken: Caller is not a minter"
        );
        _;
    }

    /**
     * @dev updateBaseTokenURI is used to set BaseURI.
     * Requirement:
     *  - This function can only called by owner
     *
     * @param _newBaseURI - New baseURI
     *
     * Emits a {UpdatedBaseURI} event.
     */
    function updateBaseTokenURI(
        string calldata _newBaseURI
    ) external onlyOwner {
        require(bytes(_newBaseURI).length != 0, "BaseURI empty");
        baseURI = _newBaseURI;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev updateMetadataHashLenght is used to update the metadataHash lenght.
     * Requirement:
     *  - This function can only called by owner
     *
     * @param _newLenght - New metadataHashLenght
     *
     * Emits a {UpdatedMetadataHashLength} event.
     */
    function updateMetadataHashLenght(uint256 _newLenght) external onlyOwner {
        metadataHashLenght = _newLenght;

        emit UpdatedMetadataHashLength(metadataHashLenght, msg.sender);
    }

    // Function to set the contract URI (accessible only by the contract owner)
    function setContractURI(string calldata newContractURI) external onlyOwner {
        contractURI = newContractURI;
    }

    // Function to perform actions before token transfer (overrides ERC721Enumerable and ERC721)
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // Function to check supported interfaces (overrides multiple contracts)
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev tokenURI is used to get tokenURI link
     * Requirement:
     * - This is a public function that can called by anyone.
     *
     * @param tokenId - NFT id
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // Function to mint an NFT with specified metadata (accessible only by the designated minter)
    function mintNFT(
        address to,
        string calldata ipfsMetadata
    ) external onlyMinter whenNotPaused {
        require(
            Address.isContract(to) == false,
            "Cannot send to contract address"
        );
        require(
            bytes(ipfsMetadata).length == metadataHashLenght,
            "Invalid metadata"
        );

        _tokenIdCounter++;
        _safeMint(to, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, ipfsMetadata);
        emit NFTMinted(msg.sender, to, _tokenIdCounter, ipfsMetadata);
    }

    // Function to bulk mint NFTs with specified metadata (accessible only by the designated minter)
    function mintBulkNFTs(
        address to,
        string calldata ipfsMetadata,
        uint256 copies
    ) external onlyMinter whenNotPaused {
        require(
            Address.isContract(to) == false,
            "Cannot send to contract address"
        );
        require(
            bytes(ipfsMetadata).length == metadataHashLenght,
            "Invalid metadata"
        );

        require(copies > 0, "Invalid number of copies");

        uint256[] memory tokenIds = new uint256[](copies);

        for (uint i = 0; i < copies; i++) {
            _tokenIdCounter++;
            _safeMint(to, _tokenIdCounter);
            _setTokenURI(_tokenIdCounter, ipfsMetadata);
            tokenIds[i] = _tokenIdCounter;
        }

        emit BulkMintedNFTs(msg.sender, to, tokenIds, ipfsMetadata);
    }

    // Function to bulk transfer NFTs to a specified address (accessible only by the contract owner)
    function transferBulkNFTs(
        address to,
        uint256[] calldata tokenIds
    ) external whenNotPaused {
        require(
            Address.isContract(to) == false,
            "Cannot send to contract address"
        );
        require(tokenIds.length > 0, "No tokens specified");

        for (uint i = 0; i < tokenIds.length; i++) {
            require(_exists(tokenIds[i]), "MyToken: NFT does not exist");
            require(
                ownerOf(tokenIds[i]) == msg.sender,
                "MyToken: Caller is not owner"
            );

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

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
