# Decentralized Identity and Access Management (IAM) dApp

## Project Title
University Credential Verification System

## Project Description

This project is a decentralized identity and academic credential verification dApp built for CSE 540. The system allows students to register decentralized identifiers (DIDs), allows approved university issuers to publish academic credential records, and allows verifiers such as employers or graduate programs to validate credential status and log verification activity.

The project uses blockchain for trust, immutability, issuer accountability, and auditability. Sensitive student data and full credential documents are intentionally kept off chain. The smart contracts store only minimal on-chain references such as DIDs, credential hashes, metadata URIs, issuer addresses, credential status, and verification log entries.

## Stakeholders

- **Student / Holder:** owns a DID and presents academic credentials to verifiers.
- **University / Issuer:** approved authority that issues or revokes credentials.
- **Verifier:** employer, graduate school, or other relying party that checks credential validity.
- **Contract Owner / Admin:** deployer account that approves trusted issuers and manages administrative credential status updates.

## Smart Contract Architecture

The implementation is organized around three Solidity contracts:

### `DIDRegistry.sol`
Manages decentralized identifiers. Users can register a DID, update DID metadata, deactivate a DID, resolve DID records, and check whether an address controls a DID.

### `AcademicCredentialRegistry.sol`
Manages university-issued academic credentials. The contract supports issuer approval, credential issuance, revocation, manual expiration, credential lookup, and validity checks. Issuance is protected by role-based access control through the approved issuer mapping.

### `VerificationLog.sol`
Records verification events in an immutable audit trail. Verifiers can log whether a credential verification result was valid or invalid without storing private academic records directly on chain.

## On-Chain and Off-Chain Data Design

The blockchain stores only the data needed for trust and verification:

- DID identifier
- DID controller address
- Public key reference
- Service endpoint reference
- DID document hash
- Credential ID
- Issuer address
- Holder DID
- Credential hash
- Metadata URI, such as an IPFS reference
- Credential status
- Verification event records

Full academic records, transcripts, and personally sensitive details should remain off chain in IPFS, Filecoin, encrypted storage, or another secure off-chain repository. The hash stored on chain allows a verifier to confirm that an off-chain record has not been modified.

## Tech Stack

- Solidity `^0.8.20`
- Hardhat
- Ethers.js / Web3.js
- MetaMask
- Local Hardhat blockchain
- Static HTML/CSS/JavaScript frontend

## Repository Structure

```text
contracts/
  DIDRegistry.sol
  AcademicCredentialRegistry.sol
  VerificationLog.sol
  interfaces/
    IDIDRegistry.sol
    IAcademicCredentialRegistry.sol
    IVerificationLog.sol

frontend_1/
  index.html
  app.js
  abi/
    DIDRegistry.json
    AcademicCredentialRegistry.json
    VerificationLog.json

scripts/
  deploy.js

test/
  iam.test.js

docs/
  FINAL_DEMO_TESTING_GUIDE.md
```

## Installation

Install dependencies from the project root:

```bash
npm ci
```

Compile the contracts:

```bash
npm run compile
```

Run the automated tests:

```bash
npm run test
```

## Local Deployment

Open one terminal and start a local Hardhat blockchain:

```bash
npm run node
```

Keep this terminal open. It will show local test accounts and private keys.

Copy these to be able to run manual tests.

Open a second terminal and deploy the contracts:

```bash
npm run deploy
```

Copy the three deployed contract addresses printed in the terminal:

```text
DIDRegistry deployed to: 0x...
AcademicCredentialRegistry deployed to: 0x...
VerificationLog deployed to: 0x...
```

## MetaMask Setup

Add the local Hardhat custom network to the MetaMask browser extension:

```text
Network Name: Hardhat Local
RPC URL: http://127.0.0.1:8545
Chain ID: 31337
Currency Symbol: ETH
```

Remember to remove the custom network before testing again. You must select another network to be able to remove the custom network.

Import one of the Hardhat test accounts as a wallet into MetaMask using a private key from the `npm run node` terminal output.

## Running the Frontend

From the project root:

```bash
npm run serve
```

Then open the local browser page, connect MetaMask, paste the deployed contract addresses, and click **Load Contracts**.

## Demo Flow

### 1. DID Registry

Register a DID:

```text
DID: did:student:100
Public Key: pubKey100
Service Endpoint: http://student100.com
Document Hash: 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

Then resolve the DID and confirm the controller address and active status.

### 2. Academic Credential Registry

Before issuing a credential, approve the connected account as an issuer:

```text
Approve Issuer Address: your connected MetaMask account address
```

Then check the same address with **Check Issuer**. Expected result:

```text
Is Approved Issuer: true
```

Issue a credential:

```text
Credential ID: cred500
Holder DID: did:student:100
Credential Hash: 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
Metadata URI: ipfs://metadata500
Expires At: 1893456000
```

Then retrieve the credential and check validity. Expected validity:

```text
Is Credential Valid: true
```

### 3. Verification Log

Log a verification event:

```text
Credential ID: cred500
Holder Address: any valid Hardhat account address
Result: Valid
```

Then retrieve verification index `0` and check total verification count.

## Testing and Error Handling

The automated test suite covers:

- DID registration, resolution, update, controller check, and deactivation
- Approved issuer flow
- Credential issuance
- Rejection of unapproved issuers
- Credential revocation and validity changes
- Verification log event creation and retrieval

Run tests with:

```bash
npm run test
```

## Security and Privacy Considerations

- Full academic records are not stored directly on chain.
- Only hashes and metadata references are stored on chain.
- Credential issuance is restricted to approved issuer addresses.
- Revocation is limited to the original issuer or contract owner.
- Verification logs provide auditability without exposing full student records.
- DID deactivation allows identity records to be marked inactive without deleting blockchain history.

## Limitations and Future Work

Future improvements could include:

- IPFS/Filecoin integration for real credential metadata storage
- Stronger decentralized governance for issuer approval
- Zero-knowledge proof support for privacy-preserving verification
- More complete student, issuer, and verifier role-specific frontend screens
- Deployment to a public testnet such as Sepolia or Polygon Amoy
- Better indexing and search support for verification history

## Team Members

Aayush Kumar  
Colin Mcateer  
Emmanuel Mnjowe  
Robert Santana-Silverio  
Tamasree Sinha
