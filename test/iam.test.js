const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Team 5 University Credential Verification System", function () {
  async function deployContracts() {
    const [owner, university, student, verifier, outsider] = await ethers.getSigners();

    const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
    const didRegistry = await DIDRegistry.deploy();
    await didRegistry.waitForDeployment();

    const AcademicCredentialRegistry = await ethers.getContractFactory("AcademicCredentialRegistry");
    const academicRegistry = await AcademicCredentialRegistry.deploy();
    await academicRegistry.waitForDeployment();

    const VerificationLog = await ethers.getContractFactory("VerificationLog");
    const verificationLog = await VerificationLog.deploy();
    await verificationLog.waitForDeployment();

    return { owner, university, student, verifier, outsider, didRegistry, academicRegistry, verificationLog };
  }

  it("registers, resolves, updates, and deactivates a DID", async function () {
    const { owner, didRegistry } = await deployContracts();

    await expect(
      didRegistry.registerDID(
        "did:team5:student123",
        "student-public-key",
        "ipfs://student-did-document",
        ethers.keccak256(ethers.toUtf8Bytes("student-did-document"))
      )
    ).to.emit(didRegistry, "DIDRegistered");

    let record = await didRegistry.resolveDID("did:team5:student123");
    expect(record.controller).to.equal(owner.address);
    expect(record.active).to.equal(true);

    expect(await didRegistry.isController("did:team5:student123", owner.address)).to.equal(true);

    await expect(
      didRegistry.updateDID(
        "did:team5:student123",
        "updated-public-key",
        "ipfs://updated-did-document",
        ethers.keccak256(ethers.toUtf8Bytes("updated-did-document"))
      )
    ).to.emit(didRegistry, "DIDUpdated");

    record = await didRegistry.resolveDID("did:team5:student123");
    expect(record.publicKey).to.equal("updated-public-key");

    await expect(didRegistry.deactivateDID("did:team5:student123")).to.emit(didRegistry, "DIDDeactivated");

    record = await didRegistry.resolveDID("did:team5:student123");
    expect(record.active).to.equal(false);
  });

  it("approves issuers and issues a valid academic credential", async function () {
    const { owner, university, academicRegistry } = await deployContracts();

    // The deployment account is auto-approved for a smoother local demo.
    expect(await academicRegistry.isApprovedIssuer(owner.address)).to.equal(true);

    await expect(academicRegistry.approveIssuer(university.address))
      .to.emit(academicRegistry, "IssuerApproved")
      .withArgs(university.address);

    expect(await academicRegistry.isApprovedIssuer(university.address)).to.equal(true);

    await expect(
      academicRegistry.connect(university).issueCredential(
        "cred-001",
        "did:team5:student123",
        ethers.keccak256(ethers.toUtf8Bytes("credential-data")),
        "ipfs://credential-data",
        0
      )
    ).to.emit(academicRegistry, "CredentialIssued");

    const record = await academicRegistry.getCredential("cred-001");
    expect(record.credentialId).to.equal("cred-001");
    expect(record.issuer).to.equal(university.address);
    expect(record.holderDID).to.equal("did:team5:student123");

    expect(await academicRegistry.isCredentialValid("cred-001")).to.equal(true);
  });

  it("rejects credential issuance from an unapproved account", async function () {
    const { outsider, academicRegistry } = await deployContracts();

    await expect(
      academicRegistry.connect(outsider).issueCredential(
        "cred-unapproved",
        "did:team5:student999",
        ethers.keccak256(ethers.toUtf8Bytes("credential-data")),
        "ipfs://credential-data",
        0
      )
    ).to.be.revertedWith("Caller is not an approved issuer");
  });

  it("revokes credentials and marks revoked credentials invalid", async function () {
    const { university, academicRegistry } = await deployContracts();

    await academicRegistry.approveIssuer(university.address);

    await academicRegistry.connect(university).issueCredential(
      "cred-002",
      "did:team5:student456",
      ethers.keccak256(ethers.toUtf8Bytes("credential-data-2")),
      "ipfs://credential-data-2",
      0
    );

    expect(await academicRegistry.isCredentialValid("cred-002")).to.equal(true);

    await expect(academicRegistry.connect(university).revokeCredential("cred-002"))
      .to.emit(academicRegistry, "CredentialRevoked");

    expect(await academicRegistry.isCredentialValid("cred-002")).to.equal(false);
  });

  it("approves a verifier", async function () {
  const { verifier, verificationLog } = await deployContracts();

  await expect(verificationLog.approveVerifier(verifier.address))
    .to.emit(verificationLog, "VerifierApproved")
    .withArgs(verifier.address);

  expect(await verificationLog.isApprovedVerifier(verifier.address)).to.equal(true);
});

it("removes an approved verifier", async function () {
  const { verifier, verificationLog } = await deployContracts();

  await verificationLog.approveVerifier(verifier.address);

  await expect(verificationLog.removeVerifier(verifier.address))
    .to.emit(verificationLog, "VerifierRemoved")
    .withArgs(verifier.address);

  expect(await verificationLog.isApprovedVerifier(verifier.address)).to.equal(false);
});

it("logs a verification event from an approved verifier", async function () {
  const { student, verifier, verificationLog } = await deployContracts();

  await verificationLog.approveVerifier(verifier.address);

  await expect(
    verificationLog.connect(verifier).logVerification("cred-001", student.address, true)
  ).to.emit(verificationLog, "VerificationLogged");

  const count = await verificationLog.getVerificationCount();
  expect(count).to.equal(1n);

  const entry = await verificationLog.getVerification(0);
  expect(entry.credentialId).to.equal("cred-001");
  expect(entry.verifier).to.equal(verifier.address);
  expect(entry.holder).to.equal(student.address);
  expect(entry.result).to.equal(true);
});

it("rejects verification logging from an unapproved verifier", async function () {
  const { student, outsider, verificationLog } = await deployContracts();
  
  await expect(
    verificationLog.connect(outsider).logVerification("cred-001", student.address, true)
  ).to.be.revertedWith("Caller is not an approved verifier");
});

it("rejects verification logging with an empty credential ID", async function () {
  const { student, verifier, verificationLog } = await deployContracts();

  await verificationLog.approveVerifier(verifier.address);

  await expect(
    verificationLog.connect(verifier).logVerification("", student.address, true)
  ).to.be.revertedWith("Credential ID is required");
});

it("rejects verification logging with an invalid holder address", async function () {
  const { verifier, verificationLog } = await deployContracts();

  await verificationLog.approveVerifier(verifier.address);

  await expect(
    verificationLog.connect(verifier).logVerification("cred-001", ethers.ZeroAddress, true)
  ).to.be.revertedWith("Invalid holder address");
});
});
