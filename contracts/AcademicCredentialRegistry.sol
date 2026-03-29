// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAcademicCredentialRegistry} from "./interfaces/IAcademicCredentialRegistry.sol";

/// @title Academic Credential Registry
/// @notice Stores on chain references and status for university issued academic credentials.
/// @dev Full credential documents remain off chain. This contract stores hashes, metadata references, and status.
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
    }

    function approveIssuer(address issuer) external override onlyOwner {
        require(issuer != address(0), "Invalid issuer address");
        approvedIssuers[issuer] = true;
        emit IssuerApproved(issuer);
    }

    function removeIssuer(address issuer) external override onlyOwner {
        approvedIssuers[issuer] = false;
        emit IssuerRemoved(issuer);
    }

    function isApprovedIssuer(address issuer) external view override returns (bool) {
        return approvedIssuers[issuer];
    }

    function issueCredential(
        string calldata credentialId,
        string calldata holderDID,
        bytes32 credentialHash,
        string calldata metadataURI,
        uint256 expiresAt
    ) external override onlyApprovedIssuer {
        require(bytes(credentialId).length > 0, "Credential ID is required");
        require(bytes(holderDID).length > 0, "Holder DID is required");
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

    function revokeCredential(string calldata credentialId) external override {
        CredentialRecord storage record = credentials[credentialId];
        require(record.issuer != address(0), "Credential does not exist");
        require(record.issuer == msg.sender || msg.sender == owner, "Not authorized to revoke");
        require(record.status == CredentialStatus.Active, "Credential is not active");

        record.status = CredentialStatus.Revoked;
        emit CredentialRevoked(credentialId, block.timestamp);
    }

    function markCredentialExpired(string calldata credentialId) external override onlyOwner {
        CredentialRecord storage record = credentials[credentialId];
        require(record.issuer != address(0), "Credential does not exist");
        require(record.status == CredentialStatus.Active, "Credential is not active");

        record.status = CredentialStatus.Expired;
        emit CredentialExpired(credentialId, block.timestamp);
    }

    function getCredential(string calldata credentialId)
        external
        view
        override
        returns (CredentialRecord memory record)
    {
        return credentials[credentialId];
    }

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
