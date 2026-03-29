// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IDIDRegistry} from "./interfaces/IDIDRegistry.sol";

/// @title DID Registry
/// @notice Stores minimal on chain references for student decentralized identifiers.
/// @dev Full DID documents remain off chain while this contract anchors ownership, metadata, and status.
contract DIDRegistry is IDIDRegistry {
    mapping(string => DIDRecord) private didRecords;

    modifier onlyController(string memory did) {
        require(didRecords[did].controller == msg.sender, "Caller is not DID controller");
        _;
    }

    function registerDID(
        string calldata did,
        string calldata publicKey,
        string calldata serviceEndpoint,
        bytes32 documentHash
    ) external override {
        require(bytes(did).length > 0, "DID is required");
        require(didRecords[did].controller == address(0), "DID already exists");

        didRecords[did] = DIDRecord({
            did: did,
            controller: msg.sender,
            publicKey: publicKey,
            serviceEndpoint: serviceEndpoint,
            documentHash: documentHash,
            active: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        emit DIDRegistered(did, msg.sender, block.timestamp);
    }

    function updateDID(
        string calldata did,
        string calldata publicKey,
        string calldata serviceEndpoint,
        bytes32 documentHash
    ) external override onlyController(did) {
        DIDRecord storage record = didRecords[did];
        require(record.active, "DID is inactive");

        record.publicKey = publicKey;
        record.serviceEndpoint = serviceEndpoint;
        record.documentHash = documentHash;
        record.updatedAt = block.timestamp;

        emit DIDUpdated(did, block.timestamp);
    }

    function deactivateDID(string calldata did) external override onlyController(did) {
        DIDRecord storage record = didRecords[did];
        require(record.active, "DID already inactive");

        record.active = false;
        record.updatedAt = block.timestamp;

        emit DIDDeactivated(did, block.timestamp);
    }

    function resolveDID(string calldata did) external view override returns (DIDRecord memory record) {
        return didRecords[did];
    }

    function isController(string calldata did, address account) external view override returns (bool) {
        return didRecords[did].controller == account;
    }
}
