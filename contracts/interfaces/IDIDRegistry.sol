// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDIDRegistry {
    struct DIDRecord {
        string did;
        address controller;
        string publicKey;
        string serviceEndpoint;
        bytes32 documentHash;
        bool active;
        uint256 createdAt;
        uint256 updatedAt;
    }

    event DIDRegistered(string did, address indexed controller, uint256 timestamp);
    event DIDUpdated(string did, uint256 timestamp);
    event DIDDeactivated(string did, uint256 timestamp);

    /// @notice Registers a new decentralized identifier for the caller.
    /// @param did The decentralized identifier string.
    /// @param publicKey A reference to the public key associated with the DID.
    /// @param serviceEndpoint A URI or endpoint associated with the DID document.
    /// @param documentHash A hash of the full DID document stored off chain.
    function registerDID(
        string calldata did,
        string calldata publicKey,
        string calldata serviceEndpoint,
        bytes32 documentHash
    ) external;

    /// @notice Updates an existing DID record.
    /// @param did The decentralized identifier string.
    /// @param publicKey The updated public key reference.
    /// @param serviceEndpoint The updated service endpoint.
    /// @param documentHash The updated hash of the off chain DID document.
    function updateDID(
        string calldata did,
        string calldata publicKey,
        string calldata serviceEndpoint,
        bytes32 documentHash
    ) external;

    /// @notice Deactivates a DID so it can no longer be treated as active.
    /// @param did The decentralized identifier string.
    function deactivateDID(string calldata did) external;

    /// @notice Resolves a DID and returns the stored on chain record.
    /// @param did The decentralized identifier string.
    /// @return record The full DID record.
    function resolveDID(string calldata did) external view returns (DIDRecord memory record);

    /// @notice Checks whether an address controls a specific DID.
    /// @param did The decentralized identifier string.
    /// @param account The address being checked.
    /// @return True if the address is the controller for the DID.
    function isController(string calldata did, address account) external view returns (bool);
}
