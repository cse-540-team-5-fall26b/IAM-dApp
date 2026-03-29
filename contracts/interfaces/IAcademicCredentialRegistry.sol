// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAcademicCredentialRegistry {
    enum CredentialStatus {
        Active,
        Revoked,
        Expired
    }

    struct CredentialRecord {
        string credentialId;
        address issuer;
        string holderDID;
        bytes32 credentialHash;
        string metadataURI;
        uint256 issuedAt;
        uint256 expiresAt;
        CredentialStatus status;
    }

    event IssuerApproved(address indexed issuer);
    event IssuerRemoved(address indexed issuer);
    event CredentialIssued(
        string credentialId,
        address indexed issuer,
        string holderDID,
        uint256 timestamp
    );
    event CredentialRevoked(string credentialId, uint256 timestamp);
    event CredentialExpired(string credentialId, uint256 timestamp);

    /// @notice Approves an address to issue academic credentials.
    /// @param issuer The address to approve.
    function approveIssuer(address issuer) external;

    /// @notice Removes issuer privileges from an address.
    /// @param issuer The address to remove.
    function removeIssuer(address issuer) external;

    /// @notice Returns whether an address is an approved issuer.
    /// @param issuer The address being checked.
    function isApprovedIssuer(address issuer) external view returns (bool);

    /// @notice Issues a new academic credential and stores its on chain reference.
    /// @param credentialId A unique credential identifier.
    /// @param holderDID The student's decentralized identifier.
    /// @param credentialHash The hash of the full credential stored off chain.
    /// @param metadataURI A URI or content identifier pointing to off chain metadata.
    /// @param expiresAt A timestamp for expiration. Use 0 if the credential does not expire.
    function issueCredential(
        string calldata credentialId,
        string calldata holderDID,
        bytes32 credentialHash,
        string calldata metadataURI,
        uint256 expiresAt
    ) external;

    /// @notice Revokes an existing academic credential.
    /// @param credentialId The unique credential identifier.
    function revokeCredential(string calldata credentialId) external;

    /// @notice Marks an academic credential as expired.
    /// @param credentialId The unique credential identifier.
    function markCredentialExpired(string calldata credentialId) external;

    /// @notice Returns the stored record for a credential.
    /// @param credentialId The unique credential identifier.
    /// @return record The credential record.
    function getCredential(string calldata credentialId)
        external
        view
        returns (CredentialRecord memory record);

    /// @notice Returns whether a credential is currently valid.
    /// @param credentialId The unique credential identifier.
    /// @return True if the credential is active and not expired.
    function isCredentialValid(string calldata credentialId) external view returns (bool);
}
