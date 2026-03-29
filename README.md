# Team 5 Decentralized IAM dApp Smart Contract Draft

## Project Description

This repository contains the draft smart contract design for Team 5's decentralized identity and access management dApp. Our project focuses on a university credential verification system in which students act as holders, the university acts as the issuer, and employers or graduate schools act as verifiers. The smart contracts are designed to support decentralized identifiers, academic credential issuance, credential status tracking, and immutable verification logging.

## Smart Contract Architecture

The design is split into three primary contracts.

`DIDRegistry.sol` manages student decentralized identifiers and anchors minimal identity metadata on chain.

`AcademicCredentialRegistry.sol` manages university issued academic credentials, including issuance, status tracking, and revocation.

`VerificationLog.sol` records verification events in an immutable audit trail without storing private academic data directly on chain.

## Off Chain Storage Design

The full DID document and full academic credential remain off chain. The blockchain stores only hashes and metadata references. This allows the system to preserve privacy while still giving issuers and verifiers a trusted on chain reference point.

## Dependencies and Setup

This repository is intended to be used with Hardhat and Solidity `^0.8.20`.

1. Install dependencies with `npm install`
2. Compile the contracts with `npx hardhat compile`
3. Run tests with `npx hardhat test`
4. Deploy with `npx hardhat run scripts/deploy.js --network hardhat`

## Current Draft Status

This is a draft milestone submission focused on contract structure, interfaces, function signatures, and documentation. The contracts are intentionally simple and designed to communicate the intended architecture clearly.

## Future Work

Future work includes stronger issuer authorization, richer off chain credential workflows, wallet based identity presentation, and frontend integration for students, issuers, and verifiers.
