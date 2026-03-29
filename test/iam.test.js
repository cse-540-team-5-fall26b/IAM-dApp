const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Team 5 IAM Draft Contracts", function () {
  it("registers a DID", async function () {
    const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
    const didRegistry = await DIDRegistry.deploy();
    await didRegistry.waitForDeployment();

    await didRegistry.registerDID(
      "did:team5:student123",
      "student-public-key",
      "ipfs://student-did-document",
      ethers.keccak256(ethers.toUtf8Bytes("student-did-document"))
    );

    const record = await didRegistry.resolveDID("did:team5:student123");
    expect(record.controller).to.not.equal(ethers.ZeroAddress);
    expect(record.active).to.equal(true);
  });

  it("issues a credential from an approved issuer", async function () {
    const [owner, university] = await ethers.getSigners();

    const AcademicCredentialRegistry = await ethers.getContractFactory("AcademicCredentialRegistry");
    const registry = await AcademicCredentialRegistry.deploy();
    await registry.waitForDeployment();

    await registry.approveIssuer(university.address);

    await registry.connect(university).issueCredential(
      "cred-001",
      "did:team5:student123",
      ethers.keccak256(ethers.toUtf8Bytes("credential-data")),
      "ipfs://credential-data",
      0
    );

    const valid = await registry.isCredentialValid("cred-001");
    expect(valid).to.equal(true);
  });
});
