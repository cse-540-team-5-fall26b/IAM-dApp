# Solidity File Descriptions

## IDIDRegistry.sol

This interface defines the core functions and events used for decentralized identifier registration and management. It establishes the expected structure for registering a DID, updating DID metadata, deactivating a DID, resolving a DID record, and checking controller ownership.

## DIDRegistry.sol

This contract implements the DID registry logic for student identities. It stores minimal on chain references for each decentralized identifier, including the controller wallet address, a public key reference, a service endpoint, and a hash of the full DID document stored off chain.

## IAcademicCredentialRegistry.sol

This interface defines the functions and events used for academic credential issuance and status tracking. It includes issuer approval, credential issuance, revocation, expiration handling, credential lookup, and validity checks.

## AcademicCredentialRegistry.sol

This contract implements the university side of the system. It stores on chain references for academic credentials such as diplomas, transcripts, certificates, and enrollment verification records. Instead of storing full credential contents on chain, it stores a credential hash, metadata reference, issuer address, holder DID, timestamps, and current status.

## IVerificationLog.sol

This interface defines the functions and events used to record credential verification activity. It creates a standard structure for logging verification results and reading verification history.

## VerificationLog.sol

This contract implements the verification audit trail. It records lightweight verification entries that include the credential id, verifier address, holder address, verification result, and timestamp. Its purpose is to improve transparency and accountability without exposing private academic data.
