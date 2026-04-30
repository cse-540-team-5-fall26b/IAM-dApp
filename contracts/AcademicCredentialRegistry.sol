// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAcademicCredentialRegistry} from "./interfaces/IAcademicCredentialRegistry.sol";

/// @title Academic Credential Registry
/// @notice Stores on-chain references and lifecycle status for university-issued academic credentials.
/// @dev Full credential documents remain off chain. This contract stores only hashes, metadata references, issuers, and status.
contract AcademicCredentialRegistry is IAcademicCredentialRegistry {
    address public owner;

    mapping(address => bool) private approvedIssuers;
    mapping(string => CredentialRecord) private credentials;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyApprovedIssuer() {
        require(approvedIssuers[msg.sender], "Caller is not an approved issuer");
        _;
    }

    constructor() {
        owner = msg.sender;

        // The deployment account represents the university administrator in the local demo.
        // Auto-approving it prevents the frontend demo from failing before any issuer has been configured.
        approvedIssuers[msg.sender] = true;
        emit IssuerApproved(msg.sender);
    }

    /// @notice Approves an address as a trusted university issuer.
    /// @dev Only the contract owner/admin can approve issuers.
    function approveIssuer(address issuer) external override onlyOwner {
        require(issuer != address(0), "Invalid issuer address");
        approvedIssuers[issuer] = true;
        emit IssuerApproved(issuer);
    }

    /// @notice Removes a previously approved issuer.
    /// @dev This does not delete credentials already issued by that address.
    function removeIssuer(address issuer) external override onlyOwner {
        require(issuer != address(0), "Invalid issuer address");
        approvedIssuers[issuer] = false;
        emit IssuerRemoved(issuer);
    }

    /// @notice Returns whether an address can issue credentials.
    function isApprovedIssuer(address issuer) external view override returns (bool) {
        return approvedIssuers[issuer];
    }

    /// @notice Issues a credential to a holder DID.
    /// @dev Only approved issuers can call this function. Credential content stays off chain.
    function issueCredential(
        string calldata credentialId,
        string calldata holderDID,
        bytes32 credentialHash,
        string calldata metadataURI,
        uint256 expiresAt
    ) external override onlyApprovedIssuer {
        require(bytes(credentialId).length > 0, "Credential ID is required");
        require(bytes(holderDID).length > 0, "Holder DID is required");
        require(credentialHash != bytes32(0), "Credential hash is required");
        require(bytes(metadataURI).length > 0, "Metadata URI is required");
        require(expiresAt == 0 || expiresAt > block.timestamp, "Credential already expired");
        require(credentials[credentialId].issuer == address(0), "Credential already exists");

        credentials[credentialId] = CredentialRecord({
            credentialId: credentialId,
            issuer: msg.sender,
            holderDID: holderDID,
            credentialHash: credentialHash,
            metadataURI: metadataURI,
            issuedAt: block.timestamp,
            expiresAt: expiresAt,
            status: CredentialStatus.Active
        });

        emit CredentialIssued(credentialId, msg.sender, holderDID, block.timestamp);
    }

    /// @notice Revokes an active credential.
    /// @dev The original issuer or owner/admin can revoke the credential.
    function revokeCredential(string calldata credentialId) external override {
        CredentialRecord storage record = credentials[credentialId];
        require(record.issuer != address(0), "Credential does not exist");
        require(record.issuer == msg.sender || msg.sender == owner, "Not authorized to revoke");
        require(record.status == CredentialStatus.Active, "Credential is not active");

        record.status = CredentialStatus.Revoked;
        emit CredentialRevoked(credentialId, block.timestamp);
    }

    /// @notice Manually marks an active credential as expired.
    /// @dev In the demo, the owner/admin controls explicit expiration updates.
    function markCredentialExpired(string calldata credentialId) external override onlyOwner {
        CredentialRecord storage record = credentials[credentialId];
        require(record.issuer != address(0), "Credential does not exist");
        require(record.status == CredentialStatus.Active, "Credential is not active");

        record.status = CredentialStatus.Expired;
        emit CredentialExpired(credentialId, block.timestamp);
    }

    /// @notice Returns the stored credential record for a credential ID.
    function getCredential(string calldata credentialId)
        external
        view
        override
        returns (CredentialRecord memory record)
    {
        return credentials[credentialId];
    }

    /// @notice Checks whether a credential exists, is active, and has not passed its expiration timestamp.
    function isCredentialValid(string calldata credentialId) external view override returns (bool) {
        CredentialRecord memory record = credentials[credentialId];

        if (record.issuer == address(0)) {
            return false;
        }

        if (record.status != CredentialStatus.Active) {
            return false;
        }

        if (record.expiresAt != 0 && block.timestamp > record.expiresAt) {
            return false;
        }

        return true;
    }
}
