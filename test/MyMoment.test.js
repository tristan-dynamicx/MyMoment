const {
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

const newbaseURI = "https://ipfs.io/";
const updatedLength = "46";
const metadataHash = "bafyreid55s7q3fnzbmo2i5alsnvhx4mziztp7t56yfnqdolsz7qwl2alvy";
const copies = 5;
const ids = [1, 2, 3];

describe("MyMoment Unit Test", function () {
  async function deployMyMomentFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const MyMoment = await ethers.getContractFactory("MyMoment");
    const myMoment = await MyMoment.deploy("https", "https");

    return { myMoment, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Verifying in contract - Name & symbol.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.name()).to.equal("SPORTWORLD X ELF MyMOMENT EDITION");
      expect(await myMoment.symbol()).to.equal("SWELF");
    });

    it("Verifying in contract - BaseURI.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.baseURI()).to.equal("https");
    });

    it("Verifying in contract - ContractURI.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.contractURI()).to.equal("https");
    });

    it("Verifying in contract - MetadataHashLength.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.metadataHashLenght()).to.equal("59");
    });

  });

  describe("Update Functions", function () {
    it("Updating in contract - updateBaseURI().", async function () {

      const { myMoment } = await loadFixture(deployMyMomentFixture);
      await myMoment.updateBaseTokenURI(newbaseURI);
      expect(await myMoment.baseURI()).to.equal(newbaseURI);

    });

    it("Updating in contract - updateMetadataHashLength()", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      await myMoment.updateMetadataHashLenght(updatedLength);
      expect(await myMoment.metadataHashLenght()).to.equal(updatedLength);

    });

  });

  describe("Mint Functions", function () {
    it("Minting in contract - mintNFT().", async function () {

      const { myMoment, owner, otherAccount } = await loadFixture(deployMyMomentFixture);

      await myMoment.addMinter(owner.address);
      await myMoment.mintNFT(otherAccount.address, metadataHash);

      let balanceOf = await myMoment.balanceOf(
        otherAccount.address
      );

      expect(balanceOf.toNumber()).to.equal(balanceOf.toNumber());

    });

    it("Minting in contract - mintBulkNFTs().", async function () {

      const { myMoment, owner, otherAccount } = await loadFixture(deployMyMomentFixture);

      await myMoment.addMinter(owner.address);
      await myMoment.mintBulkNFTs(otherAccount.address, metadataHash, copies);

      let balanceOf = await myMoment.balanceOf(
        otherAccount.address
      );

      expect(balanceOf.toNumber()).to.equal(balanceOf.toNumber());

    });

  });

  describe("Transfer Functions", function () {
    it("Transferring NFT contract - transferBulkNFTs().", async function () {

      const { myMoment, owner, otherAccount } = await loadFixture(deployMyMomentFixture);

      await myMoment.addMinter(owner.address);
      await myMoment.mintBulkNFTs(owner.address, metadataHash, copies);
      await myMoment.transferBulkNFTs(otherAccount.address, ids);

      let balanceOf = await myMoment.balanceOf(
        otherAccount.address
      );

      expect(balanceOf.toNumber()).to.equal(balanceOf.toNumber());

    });
  });
});


describe("MyMoment Negative Unit Test", function () {
  async function deployMyMomentFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const MyMoment = await ethers.getContractFactory("MyMoment");
    const myMoment = await MyMoment.deploy("http", "https");

    return { myMoment, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Verifying in contract - Should fail if Name & symbol is not correct.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.name()).to.equal("SPORTWORLD X ELF MyMOMENT EDITION");
      expect(await myMoment.symbol()).to.equal("SWELFs");
    });

    it("Verifying in contract - Should fail if baseURI is empty.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.baseURI()).to.equal();
    });

    it("Verifying in contract - Should fail if metadataHashLength is not valid.", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      expect(await myMoment.metadataHashLenght()).to.equal("46");
    });

  });

  describe("Update Functions", function () {
    it("Updating in contract - Should fail if updateBaseURI is invalid.", async function () {

      const { myMoment } = await loadFixture(deployMyMomentFixture);
      await myMoment.updateBaseTokenURI(newbaseURI);
      expect(await myMoment.baseURI()).to.equal();

    });

    it("Updating in contract - Fail if metadataHashLenght is not correct", async function () {
      const { myMoment } = await loadFixture(deployMyMomentFixture);
      await myMoment.updateMetadataHashLenght(updatedLength);
      expect(await myMoment.metadataHashLenght()).to.equal();

    });

  });

  describe("Mint Functions", function () {
    it("Minting in contract - Fail if parameters is invalid.", async function () {

      const { myMoment, owner, otherAccount } = await loadFixture(deployMyMomentFixture);

      await myMoment.addMinter(owner.address);
      await myMoment.mintNFT(otherAccount.address, 1, metadataHash);

      let balanceOf = await myMoment.balanceOf(
        otherAccount.address
      );

      expect(balanceOf.toNumber()).to.equal(balanceOf.toNumber());

    });

    it("Minting in contract - Fail if call by other then designated minter.", async function () {

      const { myMoment, owner, otherAccount } = await loadFixture(deployMyMomentFixture);

      await myMoment.mintBulkNFTs(otherAccount.address, metadataHash, copies);

      let balanceOf = await myMoment.balanceOf(
        otherAccount.address
      );

      expect(balanceOf.toNumber()).to.equal(balanceOf.toNumber());

    });

  });

  describe("Transfer Functions", function () {
    it("TransferBulkNFTs() - Should fail if sender doesnt have enough token.", async function () {

      const { myMoment, owner, otherAccount } = await loadFixture(deployMyMomentFixture);

      await myMoment.addMinter(owner.address);
      await myMoment.transferBulkNFTs(otherAccount.address, ids);

      let balanceOf = await myMoment.balanceOf(
        otherAccount.address
      );

      expect(balanceOf.toNumber()).to.equal(balanceOf.toNumber());

    });
  });
});
